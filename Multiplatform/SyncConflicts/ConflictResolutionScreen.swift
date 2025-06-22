//
//  ConflictResolutionScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/25.
//

import SwiftUI
import HealthKit
import SwiftData

struct ConflictResolutionScreen: View {
    let conflicts: [SyncConflict]
    let onResolutionComplete: (Bool) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
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
        
        let resolver = ConflictResolver(context: modelContext)
        var allSuccessful = true
        
        for conflict in conflicts {
            guard let resolution = resolutions[conflict.id] else { continue }
            
            do {
                try await resolver.resolveConflict(conflict, using: resolution)
            } catch {
                debugPrint("Failed to resolve conflict for \(conflict.id): \(error)")
                allSuccessful = false
                // Continue with other conflicts
            }
        }
        
        // Ensure SwiftData changes are committed before notifying completion
        do {
            try modelContext.save()
        } catch {
            debugPrint("Failed to save context after conflict resolution: \(error)")
            allSuccessful = false
        }
        
        isResolving = false
        onResolutionComplete(allSuccessful)
        dismiss()
    }
}

//#Preview {
//    // Create mock data for preview
//    let mockHealthKitSample = HKQuantitySample(
//        type: HKQuantityType(.numberOfAlcoholicBeverages),
//        quantity: HKQuantity(unit: .count(), doubleValue: 2.0),
//        start: Date().addingTimeInterval(-3600), // 1 hour ago
//        end: Date().addingTimeInterval(-3600)
//    )
//    
//    let mockLocalRecord = DrinkRecord(standardDrinks: 1.5, date: Date().addingTimeInterval(-3540)) // 59 minutes ago
//    mockLocalRecord.id = mockHealthKitSample.uuid.uuidString
//    
//    let mockConflict = SyncConflict(
//        id: mockHealthKitSample.uuid.uuidString,
//        healthKitSample: mockHealthKitSample,
//        localRecord: mockLocalRecord,
//        conflictTypes: [.both]
//    )
//    
//    return ConflictResolutionScreen(
//        conflicts: [mockConflict],
//        onResolutionComplete: {}
//    )
//}
