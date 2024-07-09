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
            guard try await healthStoreManager.isAuthorized() else { return }
        } catch {
            debugPrint("❌ HealthKit is not authorized. Aborting sync.")
            return
        }
        
        let drinkRecords = fetchDrinks()
        let existingRecords = convertToDictionary(drinkRecords)
        let samples = await fetchHealthkitRecords()

        reconcile(existingRecords, with: samples)
        delete(existingRecords, absentFrom: samples)
    }
    
    private func convertToDictionary(_ drinkRecords: [DrinkRecord]) -> [String: DrinkRecord] {
        var existingRecords = [String: DrinkRecord]()
        for drinkRecord in drinkRecords where existingRecords[drinkRecord.id] == nil {
            existingRecords[drinkRecord.id] = drinkRecord
        }
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
        } catch {
            debugPrint("❌ Failed to retrieve healthkit samples")
        }

        return samples
    }
    
    private func reconcile(
        _ existingRecords: [String: DrinkRecord],
        with samples: [HKQuantitySample]
    ) {
        for sample in samples {
            let count = sample.quantity.doubleValue(for: .count())
            
            // Check if a record with the same uuid exists in SwiftData
            // and update the existing record if the values are different
            if let existingRecord = existingRecords[sample.uuid.uuidString] {
                if existingRecord.standardDrinks != count {
                    existingRecord.standardDrinks = count
                }
                if existingRecord.timestamp != sample.startDate {
                    existingRecord.timestamp = sample.startDate
                }
            } else {
                // Create a new SwiftData record if it doesn't exist
                let newRecord = DrinkRecord(sample)
                context.insert(newRecord)
                debugPrint("✅ Insert new record in model context")
            }
        }
    }
    
    private func delete(
        _ existingRecords: [String: DrinkRecord],
        absentFrom samples: [HKQuantitySample]
    ) {
        let healthKitIDs = Set(samples.map { $0.uuid.uuidString })
        
        for record in existingRecords {
            if let record = existingRecords[record.key], !healthKitIDs.contains(record.id) {
                debugPrint("✅ Delete record from model context")
                context.delete(record)
            }
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
