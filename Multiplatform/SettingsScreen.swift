//
//  SettingsScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import SwiftData
import SwiftUI

struct SettingsScreen: View {
    @AppStorage("dailyTarget") private var dailyLimit = 0.0
    @AppStorage("weeklyTarget") private var weeklyLimit = 0.0
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
                limitsSection
                measurementDefaultsSection
                developerSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    .accessibilityLabel("Done")
                    .accessibilityHint("Closes settings and returns to main screen")
                }
            }
        }
        .modifier(ConfirmationDialogsModifier(
            showDeleteAllDataConfirmation: $showDeleteAllDataConfirmation,
            showSyncWithHealthKitConfirmation: $showSyncWithHealthKitConfirmation,
            showResetLongestStreakConfirmation: $showResetLongestStreakConfirmation,
            deleteAllRecords: deleteAllRecords,
            syncWithHealthKit: syncWithHealthKit,
            resetLongestStreak: { longestStreak = 0 }
        ))
    }
    
    private var limitsSection: some View {
        Section {
            Stepper {
                Text("Daily limit: \(Formatter.formatDecimal(dailyLimit))")
            } onIncrement: {
                dailyLimit += 1
                UIAccessibility.post(notification: .announcement, argument: "Daily limit set to \(Formatter.formatDecimal(dailyLimit))")
            } onDecrement: {
                if dailyLimit > 0 {
                    dailyLimit -= 1
                    UIAccessibility.post(notification: .announcement, argument: "Daily limit set to \(Formatter.formatDecimal(dailyLimit))")
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Daily drink limit")
            .accessibilityValue("\(Formatter.formatDecimal(dailyLimit)) drinks")
            .accessibilityHint("Use increment and decrement to adjust daily limit")
            
            Stepper {
                Text("Weekly limit: \(Formatter.formatDecimal(weeklyLimit))")
            } onIncrement: {
                weeklyLimit += 1
                UIAccessibility.post(notification: .announcement, argument: "Weekly limit set to \(Formatter.formatDecimal(weeklyLimit))")
            } onDecrement: {
                if weeklyLimit > 0 {
                    weeklyLimit -= 1
                    UIAccessibility.post(notification: .announcement, argument: "Weekly limit set to \(Formatter.formatDecimal(weeklyLimit))")
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Weekly drink limit")
            .accessibilityValue("\(Formatter.formatDecimal(weeklyLimit)) drinks")
            .accessibilityHint("Use increment and decrement to adjust weekly limit")
            
            Button {
                showResetLongestStreakConfirmation = true
            } label: {
                Text("Reset longest streak")
            }
            .accessibilityLabel("Reset longest streak")
            .accessibilityHint("Warning: This will reset your longest streak record to zero")
        }
    }
    
    private var measurementDefaultsSection: some View {
        Section("Measurement defaults") {
            Picker("Volume Measurement", selection: $useMetricAsDefault) {
                Text("oz").tag(false)
                    .accessibilityLabel("Ounces as default volume unit")
                Text("ml").tag(true)
                    .accessibilityLabel("Milliliters as default volume unit")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Default volume measurement")
            .accessibilityHint("Choose default unit for volume measurements")
            
            Picker("Alcohol Strength", selection: $useProofAsDefault) {
                Text("ABV %").tag(false)
                    .accessibilityLabel("ABV percentage as default alcohol strength")
                Text("Proof").tag(true)
                    .accessibilityLabel("Proof as default alcohol strength")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Default alcohol strength measurement")
            .accessibilityHint("Choose default unit for alcohol strength measurements")
        }
    }
    
    private var developerSection: some View {
        Section("Developer") {
            Button {
                showDeleteAllDataConfirmation = true
            } label: {
                Text("Delete all SwiftData")
                    .foregroundColor(.red)
            }
            .accessibilityLabel("Delete all data")
            .accessibilityHint("Warning: This will permanently delete all recorded drinks")
            .accessibilityAddTraits(.isButton)
            
            Button {
                showSyncWithHealthKitConfirmation = true
            } label: {
                Text("Sync with HealthKit")
            }
            .accessibilityLabel("Sync with HealthKit")
            .accessibilityHint("Synchronizes local drink records with Apple HealthKit")
        }
    }
    
    private func deleteAllRecords() {
        for record in drinkRecords {
            modelContext.delete(record)
        }
    }
    
    private func syncWithHealthKit() async {
        let synchronizer = DataSynchronizer(context: modelContext)
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

struct ConfirmationDialogsModifier: ViewModifier {
    @Binding var showDeleteAllDataConfirmation: Bool
    @Binding var showSyncWithHealthKitConfirmation: Bool
    @Binding var showResetLongestStreakConfirmation: Bool
    let deleteAllRecords: () -> Void
    let syncWithHealthKit: () async -> Void
    let resetLongestStreak: () -> Void
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "Delete everything from local storage?",
                isPresented: $showDeleteAllDataConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancel", role: .cancel) { }
                    .accessibilityLabel("Cancel deletion")
                    .accessibilityHint("Cancels the deletion and keeps all data")
                
                Button("Delete All", role: .destructive) {
                    deleteAllRecords()
                }
                .accessibilityLabel("Confirm delete all")
                .accessibilityHint("Permanently deletes all drink records from local storage")
            }
            .confirmationDialog(
                "Sync local storage with HealthKit?",
                isPresented: $showSyncWithHealthKitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancel", role: .cancel) { }
                    .accessibilityLabel("Cancel sync")
                    .accessibilityHint("Cancels synchronization with HealthKit")
                
                Button("Sync") {
                    Task { await syncWithHealthKit() }
                }
                .accessibilityLabel("Start sync")
                .accessibilityHint("Begins synchronizing drink records with Apple HealthKit")
            }
            .confirmationDialog(
                "Reset longest streak to zero?",
                isPresented: $showResetLongestStreakConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancel", role: .cancel) { }
                    .accessibilityLabel("Cancel reset")
                    .accessibilityHint("Cancels resetting longest streak")
                
                Button("Reset") {
                    resetLongestStreak()
                }
                .accessibilityLabel("Confirm reset")
                .accessibilityHint("Resets your longest streak record to zero")
            }
    }
}
