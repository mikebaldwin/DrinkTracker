//
//  DataSynchronizer.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/13/24.
//

import Foundation
import SwiftData
import HealthKit

actor DataSynchronizer {
    
    private var healthStoreManager = HealthStoreManager.shared
    private var context: ModelContext
    
    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }
    
    func updateDrinkRecords() async {
        do {
            guard try await healthStoreManager.isAuthorized() else {
                debugPrint("%%% ❌ HealthKit is not authorized. Aborting sync.")
                return
            }
            
            let drinkRecords = fetchDrinks()
            debugPrint("%%% 📊 Found \(drinkRecords.count) existing drink records in SwiftData")
            
            let existingRecords = convertToDictionary(drinkRecords)
            let samples = await fetchHealthkitRecords()
            debugPrint("%%% 📊 Found \(samples.count) drink samples in HealthKit")

            reconcile(existingRecords, with: samples)
            delete(existingRecords, absentFrom: samples)
            
            debugPrint("%%% ✅ Sync completed successfully")
        } catch {
            debugPrint("%%% ❌ Error during sync: \(error)")
        }
    }
    
    private func convertToDictionary(_ drinkRecords: [DrinkRecord]) -> [String: DrinkRecord] {
        debugPrint("%%% 📊 Converting \(drinkRecords.count) existing records to dictionary")
        var existingRecords = [String: DrinkRecord]()
        
        for drinkRecord in drinkRecords {
            if existingRecords[drinkRecord.id] != nil {
                debugPrint("%%% ⚠️ Found duplicate record with ID: \(drinkRecord.id)")
                // If we find a duplicate, delete it
                context.delete(drinkRecord)
                debugPrint("%%% 🗑️ Deleted duplicate record")
            } else {
                existingRecords[drinkRecord.id] = drinkRecord
                debugPrint("%%% ✅ Added record to dictionary: \(drinkRecord.id) from \(drinkRecord.timestamp)")
            }
        }
        
        debugPrint("%%% 📊 Dictionary contains \(existingRecords.count) unique records")
        return existingRecords
    }
    
    private func fetchDrinks() -> [DrinkRecord] {
        let drinkRecords = FetchDescriptor<DrinkRecord>()
        do {
            let results = try context.fetch(drinkRecords)
            return results
        } catch {
            debugPrint("❌ Failed to fetch drink records")
        }
        return []
    }
    
    private func fetchHealthkitRecords() async -> [HKQuantitySample] {
        var samples = [HKQuantitySample]()
        
        do {
            samples = try await healthStoreManager.fetchAllDrinkSamples()
            debugPrint("%%% 📊 Retrieved \(samples.count) samples from HealthKit")
            
            // Log the dates of the samples to help debug
            for sample in samples {
                debugPrint("%%% 📅 Sample from \(sample.startDate) with \(sample.quantity.doubleValue(for: .count())) drinks")
            }
        } catch {
            debugPrint("%%% ❌ Failed to retrieve healthkit samples: \(error)")
        }

        return samples
    }
    
    private func reconcile(
        _ existingRecords: [String: DrinkRecord],
        with samples: [HKQuantitySample]
    ) {
        var newRecords: [DrinkRecord] = []
        var updatedRecords: [DrinkRecord] = []
        
        for sample in samples {
            let count = sample.quantity.doubleValue(for: .count())
            
            // Only check for records with matching UUID
            if let existingRecord = existingRecords[sample.uuid.uuidString] {
                debugPrint("%%% 🔄 Found existing record with matching UUID: \(sample.uuid.uuidString)")
                var needsUpdate = false
                
                if existingRecord.standardDrinks != count {
                    existingRecord.standardDrinks = count
                    needsUpdate = true
                    debugPrint("%%% 📝 Updated drink count for existing record")
                }
                if existingRecord.timestamp != sample.startDate {
                    existingRecord.timestamp = sample.startDate
                    needsUpdate = true
                    debugPrint("%%% 📝 Updated timestamp for existing record")
                }
                
                if needsUpdate {
                    updatedRecords.append(existingRecord)
                }
            } else {
                // Create a new record for any sample without a matching UUID
                debugPrint("%%% ➕ Creating new record for sample from \(sample.startDate)")
                let newRecord = DrinkRecord(sample)
                newRecords.append(newRecord)
                debugPrint("%%% ✅ Added new record to batch")
            }
        }
        
        // Batch insert all new records
        if !newRecords.isEmpty {
            for record in newRecords {
                context.insert(record)
            }
            do {
                try context.save()
            } catch {
                fatalError("Failed to save context: \(error)")
            }
            debugPrint("%%% 📦 Batch inserted \(newRecords.count) new records")
        }
        
        // Log any updated records
        if !updatedRecords.isEmpty {
            debugPrint("%%% 📝 Updated \(updatedRecords.count) existing records")
        }
    }
    
    private func delete(
        _ existingRecords: [String: DrinkRecord],
        absentFrom samples: [HKQuantitySample]
    ) {
        let healthKitIDs = Set(samples.map { $0.uuid.uuidString })
        var recordsToDelete: [DrinkRecord] = []
        
        for (_, record) in existingRecords {
            if !healthKitIDs.contains(record.id) {
                debugPrint("%%% 🗑️ Found record to delete: \(record.id) from \(record.timestamp)")
                recordsToDelete.append(record)
            }
        }
        
        if !recordsToDelete.isEmpty {
            for record in recordsToDelete {
                context.delete(record)
            }
            debugPrint("%%% 📦 Batch deleted \(recordsToDelete.count) records")
        }
    }
}

fileprivate extension DrinkRecord {
    convenience init(_ sample: HKQuantitySample) {
        self.init(
            standardDrinks: sample.quantity.doubleValue(for: .count()),
            date: sample.startDate
        )
        self.id = sample.uuid.uuidString
    }
}
