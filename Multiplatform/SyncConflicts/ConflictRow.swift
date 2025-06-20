//
//  ConflictRow.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/25.
//

import Foundation
import SwiftUI

struct ConflictRow: View {
    let conflict: SyncConflict
    let resolution: ConflictResolution?
    let onResolutionChanged: (ConflictResolution) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drink from \(formatDate(conflict.displayDate))")
                .font(.headline)
            
            ForEach(conflict.conflictTypes, id: \.description) { conflictType in
                Text(conflictType.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let healthKitSample = conflict.healthKitSample {
                HStack(spacing: 20) {
                    VStack {
                        Text("HealthKit")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("\(Formatter.formatDecimal(healthKitSample.quantity.doubleValue(for: .count()))) drinks")
                        Text(formatTime(healthKitSample.startDate))
                            .font(.caption2)
                        
                        Button("Use This") {
                            onResolutionChanged(.useHealthKit)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(resolution == .useHealthKit ? .white : .blue)
                        .background(resolution == .useHealthKit ? .blue : .clear)
                    }
                    
                    VStack {
                        Text("DrinkTracker")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("\(Formatter.formatDecimal(conflict.localRecord.standardDrinks)) drinks")
                        Text(formatTime(conflict.localRecord.timestamp))
                            .font(.caption2)
                        
                        Button("Use This") {
                            onResolutionChanged(.useLocal)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(resolution == .useLocal ? .white : .blue)
                        .background(resolution == .useLocal ? .blue : .clear)
                    }
                }
            } else {
                // Record was deleted from HealthKit
                VStack(spacing: 12) {
                    Text("This record was deleted from HealthKit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    VStack {
                        Text("DrinkTracker Record")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("\(Formatter.formatDecimal(conflict.localRecord.standardDrinks)) drinks")
                        Text(formatTime(conflict.localRecord.timestamp))
                            .font(.caption2)
                    }
                    
                    HStack(spacing: 12) {
                        Button("Keep Local Record") {
                            onResolutionChanged(.useLocal)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(resolution == .useLocal ? .white : .blue)
                        .background(resolution == .useLocal ? .blue : .clear)
                        
                        Button("Delete Local Record") {
                            onResolutionChanged(.deleteLocal)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(resolution == .deleteLocal ? .white : .red)
                        .background(resolution == .deleteLocal ? .red : .clear)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
