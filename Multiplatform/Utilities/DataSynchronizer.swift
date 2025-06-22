//
//  DataSynchronizer.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/13/24.
//

import Foundation
import SwiftData
import HealthKit
import OSLog

actor DataSynchronizer {
    
    private var healthStoreManager = HealthStoreManager.shared
    private var context: ModelContext
    private var detectedConflicts: [SyncConflict] = []
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func updateDrinkRecords() async {
        do {
            guard try await healthStoreManager.isAuthorized() else {
                Logger.dataSync.warning("HealthKit not authorized, aborting sync")
                return
            }
            
            // Process any pending changes to see recent conflict resolution updates
            try context.save()
            
            // First, check for conflicts
            let conflicts = await detectConflicts()
            
            if !conflicts.isEmpty {
                Logger.dataSync.warning("Found \(conflicts.count, privacy: .public) sync conflicts requiring user resolution")
                // Post notification that conflicts exist
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .syncConflictsDetected,
                        object: conflicts
                    )
                }
                return
            }
            
            // If no conflicts, proceed with normal sync
            let drinkRecords = fetchDrinks()
            Logger.dataSync.info("Found \(drinkRecords.count, privacy: .public) existing drink records in SwiftData")
            
            let existingRecords = convertToDictionary(drinkRecords)
            let samples = await fetchHealthkitRecords()
            Logger.dataSync.info("Found \(samples.count, privacy: .public) drink samples in HealthKit")

            reconcile(existingRecords, with: samples)
            delete(existingRecords, absentFrom: samples)
            
            Logger.dataSync.info("Data sync completed successfully")
        } catch {
            Logger.dataSync.error("Error during sync: \(error.localizedDescription)")
        }
    }
    
    private func convertToDictionary(_ drinkRecords: [DrinkRecord]) -> [String: DrinkRecord] {
        Logger.dataSync.debug("Converting \(drinkRecords.count, privacy: .public) existing records to dictionary")
        var existingRecords = [String: DrinkRecord]()
        
        for drinkRecord in drinkRecords {
            if existingRecords[drinkRecord.id] != nil {
                Logger.dataSync.warning("Found duplicate record with ID: \(drinkRecord.id, privacy: .private)")
                // If we find a duplicate, delete it
                context.delete(drinkRecord)
                Logger.dataSync.info("Deleted duplicate record")
            } else {
                existingRecords[drinkRecord.id] = drinkRecord
                Logger.dataSync.debug("Added record to dictionary: \(drinkRecord.id, privacy: .private)")
            }
        }
        
        Logger.dataSync.debug("Dictionary contains \(existingRecords.count, privacy: .public) unique records")
        return existingRecords
    }
    
    private func fetchDrinks() -> [DrinkRecord] {
        let drinkRecords = FetchDescriptor<DrinkRecord>()
        do {
            let results = try context.fetch(drinkRecords)
            return results
        } catch {
            Logger.dataSync.error("Failed to fetch drink records: \(error.localizedDescription)")
        }
        return []
    }
    
    private func fetchHealthkitRecords() async -> [HKQuantitySample] {
        var samples = [HKQuantitySample]()
        
        do {
            samples = try await healthStoreManager.fetchAllDrinkSamples()
            Logger.dataSync.info("Retrieved \(samples.count, privacy: .public) samples from HealthKit")
            
            // Log the dates of the samples to help debug
            Logger.dataSync.debug("Retrieved HealthKit samples with detailed timing information")
        } catch {
            Logger.dataSync.error("Failed to retrieve HealthKit samples: \(error.localizedDescription)")
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
                Logger.dataSync.debug("Found existing record with matching UUID: \(sample.uuid.uuidString, privacy: .private)")
                var needsUpdate = false
                
                if existingRecord.standardDrinks != count {
                    existingRecord.standardDrinks = count
                    needsUpdate = true
                    Logger.dataSync.debug("Updated drink count for existing record")
                }
                if existingRecord.timestamp != sample.startDate {
                    existingRecord.timestamp = sample.startDate
                    needsUpdate = true
                    Logger.dataSync.debug("Updated timestamp for existing record")
                }
                
                if needsUpdate {
                    updatedRecords.append(existingRecord)
                }
            } else {
                // Create a new record for any sample without a matching UUID
                Logger.dataSync.debug("Creating new record for HealthKit sample")
                let newRecord = DrinkRecord(sample)
                newRecords.append(newRecord)
                Logger.dataSync.debug("Added new record to batch")
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
            Logger.dataSync.info("Batch inserted \(newRecords.count, privacy: .public) new records")
        }
        
        // Log any updated records
        if !updatedRecords.isEmpty {
            Logger.dataSync.info("Updated \(updatedRecords.count, privacy: .public) existing records")
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
                Logger.dataSync.debug("Found record to delete: \(record.id, privacy: .private)")
                recordsToDelete.append(record)
            }
        }
        
        if !recordsToDelete.isEmpty {
            for record in recordsToDelete {
                context.delete(record)
            }
            Logger.dataSync.info("Batch deleted \(recordsToDelete.count, privacy: .public) records")
        }
    }
    
    func detectConflicts() async -> [SyncConflict] {
        // Clear previous conflicts
        detectedConflicts.removeAll()
        
        let drinkRecords = fetchDrinks()
        let samples = await fetchHealthkitRecords()
        let existingRecords = convertToDictionary(drinkRecords)
        
        // Compare each HealthKit sample with corresponding local record
        for sample in samples {
            if let localRecord = existingRecords[sample.uuid.uuidString] {
                let conflicts = compareRecords(sample: sample, localRecord: localRecord)
                if !conflicts.isEmpty {
                    let syncConflict = SyncConflict(
                        id: sample.uuid.uuidString,
                        healthKitSample: sample,
                        localRecord: localRecord,
                        conflictTypes: conflicts
                    )
                    detectedConflicts.append(syncConflict)
                }
            }
        }
        
        // Check for local records that don't exist in HealthKit (deleted from HealthKit)
        let healthKitIDs = Set(samples.map { $0.uuid.uuidString })
        for (recordID, localRecord) in existingRecords {
            if !healthKitIDs.contains(recordID) {
                Logger.dataSync.warning("Detected record deleted from HealthKit: \(recordID, privacy: .private)")
                let syncConflict = SyncConflict(
                    id: recordID,
                    healthKitSample: nil,
                    localRecord: localRecord,
                    conflictTypes: [.deletedFromHealthKit]
                )
                detectedConflicts.append(syncConflict)
            }
        }
        
        return detectedConflicts
    }
    
    private func compareRecords(sample: HKQuantitySample, localRecord: DrinkRecord) -> [ConflictType] {
        var conflicts: [ConflictType] = []
        
        let hkAmount = sample.quantity.doubleValue(for: .count())
        let localAmount = localRecord.standardDrinks
        let hkDate = sample.startDate
        let localDate = localRecord.timestamp
        
        let amountDiffers = abs(hkAmount - localAmount) > 0.01
        let dateDiffers = abs(hkDate.timeIntervalSince(localDate)) > 60 // 1 minute tolerance
        
        if amountDiffers && dateDiffers {
            conflicts.append(.both)
        } else if amountDiffers {
            conflicts.append(.standardDrinks(healthKit: hkAmount, local: localAmount))
        } else if dateDiffers {
            conflicts.append(.timestamp(healthKit: hkDate, local: localDate))
        }
        
        return conflicts
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
