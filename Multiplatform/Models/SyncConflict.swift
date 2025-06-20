//
//  SyncConflict.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/25.
//

import Foundation
import HealthKit

struct SyncConflict: Identifiable {
    let id: String  // UUID of the record
    let healthKitSample: HKQuantitySample?
    let localRecord: DrinkRecord
    let conflictTypes: [ConflictType]
    
    var displayDate: Date {
        // Use HealthKit date as primary for display, fallback to local
        healthKitSample?.startDate ?? localRecord.timestamp
    }
}

enum ConflictType {
    case standardDrinks(healthKit: Double, local: Double)
    case timestamp(healthKit: Date, local: Date)
    case both
    case deletedFromHealthKit
    
    var description: String {
        switch self {
        case .standardDrinks(let hk, let local):
            return "Amount differs: HealthKit \(Formatter.formatDecimal(hk)) vs Local \(Formatter.formatDecimal(local))"
        case .timestamp(let hk, let local):
            return "Time differs: HealthKit \(formatShort(hk)) vs Local \(formatShort(local))"
        case .both:
            return "Both amount and time differ"
        case .deletedFromHealthKit:
            return "Record was deleted from HealthKit but still exists locally"
        }
    }
    
    private func formatShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}