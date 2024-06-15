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
        
        // create dictionary of existing drink records for faster lookup
        let existingRecords = Dictionary(uniqueKeysWithValues: drinkRecords.map { ($0.id, $0) })
        
        // fetch healthkit records
        var samples: [HKQuantitySample]?
        
        do {
            samples = try await healthStoreManager.fetchAllDrinkSamples()
        } catch {
            debugPrint("❌ Failed to retrieve healthkit samples")
        }
        
        guard let samples else { return }
        
        // iterate through healthkit records
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
        
        // delete any SwiftData records that don't exist in healthkit
        let healthKitDates = Set(samples.map { $0.uuid.uuidString })
        
        for record in existingRecords {
            // NOTE: if the user declines healthkit access, this will continually
            // delete all their saved data
            if let record = existingRecords[record.key], !healthKitDates.contains(record.id) {
                debugPrint("✅ Delete record from model context")
                context.delete(record)
            }
        }
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
