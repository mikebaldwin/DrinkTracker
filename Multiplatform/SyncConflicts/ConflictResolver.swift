//
//  ConflictResolver.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/25.
//

import Foundation
import HealthKit
import SwiftData

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
        }
    }
    
    private func useHealthKitVersion(_ conflict: SyncConflict) async throws {
        // Update local record to match HealthKit
        let localRecord = conflict.localRecord
        let healthKitSample = conflict.healthKitSample
        
        localRecord.standardDrinks = healthKitSample.quantity.doubleValue(for: .count())
        localRecord.timestamp = healthKitSample.startDate
        
        // Save changes to SwiftData
        try context.save()
        
        debugPrint("✅ Updated local record to match HealthKit for \(conflict.id)")
    }
    
    private func useLocalVersion(_ conflict: SyncConflict) async throws {
        // Update HealthKit to match local record
        let localRecord = conflict.localRecord
        
        // Delete existing HealthKit sample
        try await healthStoreManager.deleteAlcoholicBeverage(
            withUUID: UUID(uuidString: conflict.id)!
        )
        
        // Create new HealthKit sample with local values
        let newSample = HKQuantitySample(
            type: HKQuantityType(.numberOfAlcoholicBeverages),
            quantity: HKQuantity(unit: .count(), doubleValue: localRecord.standardDrinks),
            start: localRecord.timestamp,
            end: localRecord.timestamp
        )
        
        try await healthStoreManager.save(newSample)
        
        // Update local record ID to match new HealthKit sample
        localRecord.id = newSample.uuid.uuidString
        
        // Save changes to SwiftData
        try context.save()
        
        debugPrint("✅ Updated HealthKit to match local record for \(conflict.id)")
    }
}