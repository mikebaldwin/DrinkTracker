//
//  ConflictResolver.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/25.
//

import Foundation
import HealthKit
import SwiftData
import OSLog

actor ConflictResolver {
    private let healthStoreManager = HealthStoreManager.shared
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func resolveConflict(_ conflict: SyncConflict, using resolution: ConflictResolution) async throws {
        switch resolution {
        case .useHealthKit:
            try await useHealthKitVersion(conflict)
        case .useLocal:
            try await useLocalVersion(conflict)
        case .deleteLocal:
            try await deleteLocalVersion(conflict)
        }
    }
    
    private func useHealthKitVersion(_ conflict: SyncConflict) async throws {
        guard let healthKitSample = conflict.healthKitSample else {
            throw ConflictResolutionError.noHealthKitSample
        }
        
        // Update local record to match HealthKit
        let localRecord = conflict.localRecord
        
        localRecord.standardDrinks = healthKitSample.quantity.doubleValue(for: HKUnit.count())
        localRecord.timestamp = healthKitSample.startDate
        
        // Save changes to SwiftData
        try context.save()
        
        Logger.dataSync.info("Updated local record to match HealthKit for \(conflict.id)")
    }
    
    private func useLocalVersion(_ conflict: SyncConflict) async throws {
        // Update HealthKit to match local record
        let localRecord = conflict.localRecord
        
        // Delete existing HealthKit sample if it exists
        if let healthKitSample = conflict.healthKitSample,
           let uuid = UUID(uuidString: conflict.id) {
            try await healthStoreManager.deleteAlcoholicBeverage(withUUID: uuid)
        }
        
        // Create new HealthKit sample with local values
        let newSample = HKQuantitySample(
            type: HKQuantityType(.numberOfAlcoholicBeverages),
            quantity: HKQuantity(unit: HKUnit.count(), doubleValue: localRecord.standardDrinks),
            start: localRecord.timestamp,
            end: localRecord.timestamp
        )
        
        try await healthStoreManager.save(newSample)
        
        // Update local record ID to match new HealthKit sample
        localRecord.id = newSample.uuid.uuidString
        
        // Save changes to SwiftData
        try context.save()
        
        Logger.dataSync.info("Updated HealthKit to match local record for \(conflict.id)")
    }
    
    private func deleteLocalVersion(_ conflict: SyncConflict) async throws {
        // Delete the local record
        let localRecord = conflict.localRecord
        context.delete(localRecord)
        
        // Save changes to SwiftData
        try context.save()
        
        Logger.dataSync.info("Deleted local record for \(conflict.id)")
    }
}

enum ConflictResolutionError: Error {
    case noHealthKitSample
}