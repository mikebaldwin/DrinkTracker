//
//  ConflictResolutionScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/25.
//

import SwiftUI
import HealthKit

struct ConflictResolutionScreen: View {
    let conflicts: [SyncConflict]
    let onResolutionComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var resolutions: [String: ConflictResolution] = [:]
    @State private var isResolving = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Sync Conflicts Found")) {
                    Text("\(conflicts.count) record(s) have differences between HealthKit and DrinkTracker. Choose which version to keep.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                ForEach(conflicts) { conflict in
                    ConflictRow(
                        conflict: conflict,
                        resolution: resolutions[conflict.id],
                        onResolutionChanged: { resolution in
                            resolutions[conflict.id] = resolution
                        }
                    )
                }
            }
            .navigationTitle("Resolve Conflicts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        Task {
                            await resolveConflicts()
                        }
                    }
                    .disabled(!allConflictsResolved || isResolving)
                }
            }
        }
    }
    
    private var allConflictsResolved: Bool {
        conflicts.allSatisfy { resolutions[$0.id] != nil }
    }
    
    private func resolveConflicts() async {
        isResolving = true
        
        let resolver = ConflictResolver()
        
        for conflict in conflicts {
            guard let resolution = resolutions[conflict.id] else { continue }
            
            do {
                try await resolver.resolveConflict(conflict, using: resolution)
            } catch {
                debugPrint("Failed to resolve conflict for \(conflict.id): \(error)")
                // Continue with other conflicts
            }
        }
        
        isResolving = false
        onResolutionComplete()
        dismiss()
    }
}

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
            
            HStack(spacing: 20) {
                VStack {
                    Text("HealthKit")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("\(Formatter.formatDecimal(conflict.healthKitSample.quantity.doubleValue(for: .count()))) drinks")
                    Text(formatTime(conflict.healthKitSample.startDate))
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

enum ConflictResolution {
    case useHealthKit
    case useLocal
}

#Preview {
    // Create mock data for preview
    let mockHealthKitSample = HKQuantitySample(
        type: HKQuantityType(.numberOfAlcoholicBeverages),
        quantity: HKQuantity(unit: .count(), doubleValue: 2.0),
        start: Date().addingTimeInterval(-3600), // 1 hour ago
        end: Date().addingTimeInterval(-3600)
    )
    
    let mockLocalRecord = DrinkRecord(standardDrinks: 1.5, date: Date().addingTimeInterval(-3540)) // 59 minutes ago
    mockLocalRecord.id = mockHealthKitSample.uuid.uuidString
    
    let mockConflict = SyncConflict(
        id: mockHealthKitSample.uuid.uuidString,
        healthKitSample: mockHealthKitSample,
        localRecord: mockLocalRecord,
        conflictTypes: [.both]
    )
    
    return ConflictResolutionScreen(
        conflicts: [mockConflict],
        onResolutionComplete: {}
    )
}