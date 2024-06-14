//
//  SettingsScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import SwiftData
import SwiftUI

struct SettingsScreen: View {
    @AppStorage("dailyTarget") private var dailyTarget = 0.0
    @AppStorage("weeklyTarget") private var weeklyTarget = 0.0
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var drinkRecords: [DrinkRecord]
    
    @State private var showDeleteAllDataConfirmation = false
    @State private var showSyncWithHealthKitConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper {
                        Text("Daily target: \(Formatter.formatDecimal(dailyTarget))")
                    } onIncrement: {
                        dailyTarget += 1
                    } onDecrement: {
                        if dailyTarget > 0 {
                            dailyTarget -= 1
                        }
                    }
                    Stepper {
                        Text("Weekly target: \(Formatter.formatDecimal(weeklyTarget))")
                    } onIncrement: {
                        weeklyTarget += 1
                    } onDecrement: {
                        if weeklyTarget > 0 {
                            weeklyTarget -= 1
                        }
                    }
                }
                Section("Developer") {
                    Button {
                        showDeleteAllDataConfirmation = true
                    } label: {
                        Text("Delete all SwiftData")
                    }
                    Button {
                        showSyncWithHealthKitConfirmation = true
                    } label: {
                        Text("Sync with HealthKit")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete everything from local storage?",
            isPresented: $showDeleteAllDataConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllRecords()
            }
        }
        .confirmationDialog(
            "Sync local storage with HealthKit?",
            isPresented: $showSyncWithHealthKitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Sync") {
                Task { await syncWithHealthKit() }
            }
        }
    }
    
    private func deleteAllRecords() {
        for record in drinkRecords {
            modelContext.delete(record)
        }
    }
    
    private func syncWithHealthKit() async {
        let synchronizer = DataSynchronizer(container: modelContext.container)
        await synchronizer.updateDrinkRecords()
    }
}

//#Preview {
//    SettingsScreen()
//}
