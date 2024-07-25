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
    @AppStorage("longestStreak") private var longestStreak = 0
    @AppStorage("useMetricAsDefault") private var useMetricAsDefault = false
    @AppStorage("useProofAsDefault") private var useProofAsDefault = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var drinkRecords: [DrinkRecord]
    
    @State private var showDeleteAllDataConfirmation = false
    @State private var showSyncWithHealthKitConfirmation = false
    @State private var showResetLongestStreakConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper {
                        Text("Daily limit: \(Formatter.formatDecimal(dailyTarget))")
                    } onIncrement: {
                        dailyTarget += 1
                    } onDecrement: {
                        if dailyTarget > 0 {
                            dailyTarget -= 1
                        }
                    }
                    Stepper {
                        Text("Weekly limit: \(Formatter.formatDecimal(weeklyTarget))")
                    } onIncrement: {
                        weeklyTarget += 1
                    } onDecrement: {
                        if weeklyTarget > 0 {
                            weeklyTarget -= 1
                        }
                    }
                    Button {
                        longestStreak = 0
                    } label: {
                        Text("Reset longest streak")
                    }
                }
                Section("Measurement defaults") {
                    Picker("Volume Measurement", selection: $useMetricAsDefault) {
                        Text("oz").tag(false)
                        Text("ml").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Alcohol Strength", selection: $useProofAsDefault) {
                        Text("ABV %").tag(false)
                        Text("Proof").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Developer") {
                    Button {
                        showDeleteAllDataConfirmation = true
                    } label: {
                        Text("Delete all SwiftData")
                    }
                    Button {
                        showResetLongestStreakConfirmation = true
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
        .confirmationDialog(
            "Reset longest streak to zero?",
            isPresented: $showResetLongestStreakConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Reset") {
                longestStreak = 0
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self,
        configurations: config
    )

    SettingsScreen()
        .modelContainer(container)
}
