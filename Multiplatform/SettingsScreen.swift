//
//  SettingsScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import SwiftData
import SwiftUI

struct SettingsScreen: View {
    @Environment(SettingsStore.self) private var settingsStore

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var drinkRecords: [DrinkRecord]
    
    @State private var showDeleteAllDataConfirmation = false
    @State private var showSyncWithHealthKitConfirmation = false
    @State private var showResetLongestStreakConfirmation = false
    @State private var showResetHealingProgressConfirmation = false
    @State private var showTestDataGenerationOptions = false
    @State private var showGenerationConfirmation = false
    @State private var selectedProfile: TestDataDrinkingProfile?
    @State private var isGeneratingData = false
    @State private var generationProgress: Double = 0.0
    @State private var showMonthlySpendAlert = false
    @State private var monthlySpendText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                limitsSection
                measurementDefaultsSection
                drinkingStatusSection
                savingsSection
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
        .overlay {
            if isGeneratingData {
                ProgressView("Generating test data...", value: generationProgress, total: 1.0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        .modifier(ConfirmationDialogsModifier(
            showDeleteAllDataConfirmation: $showDeleteAllDataConfirmation,
            showSyncWithHealthKitConfirmation: $showSyncWithHealthKitConfirmation,
            showResetLongestStreakConfirmation: $showResetLongestStreakConfirmation,
            showResetHealingProgressConfirmation: $showResetHealingProgressConfirmation,
            showTestDataGenerationOptions: $showTestDataGenerationOptions,
            showGenerationConfirmation: $showGenerationConfirmation,
            selectedProfile: $selectedProfile,
            deleteAllRecords: deleteAllRecords,
            syncWithHealthKit: syncWithHealthKit,
            resetLongestStreak: { 
                settingsStore.longestStreak = 0
            },
            resetHealingProgress: {
                settingsStore.resetHealingProgress()
            },
            generateTestData: generateTestData
        ))
        .alert("Monthly Alcohol Spending", isPresented: $showMonthlySpendAlert) {
            TextField("Amount", text: $monthlySpendText)
                .keyboardType(.decimalPad)
                .accessibilityLabel("Monthly spending amount")
                .accessibilityHint("Enter average monthly spending on alcohol")
            
            Button("Cancel", role: .cancel) {
                monthlySpendText = ""
            }
            .accessibilityLabel("Cancel")
            .accessibilityHint("Cancels editing monthly spending")
            
            Button("Save") {
                if let amount = Double(monthlySpendText), amount >= 0 {
                    settingsStore.monthlyAlcoholSpend = amount
                }
                monthlySpendText = ""
            }
            .accessibilityLabel("Save amount")
            .accessibilityHint("Saves the entered monthly spending amount")
        } message: {
            Text("Enter your average monthly spending on alcohol to track savings during alcohol-free streaks.")
        }
        .onChange(of: showMonthlySpendAlert) { _, isPresented in
            if isPresented {
                monthlySpendText = settingsStore.monthlyAlcoholSpend > 0 ? String(settingsStore.monthlyAlcoholSpend) : ""
            }
        }
    }
    
    private var limitsSection: some View {
        Section {
            Stepper {
                Text("Daily limit: \(Formatter.formatDecimal(settingsStore.dailyLimit))")
            } onIncrement: {
                settingsStore.dailyLimit += 1
                UIAccessibility.post(notification: .announcement, argument: "Daily limit set to \(Formatter.formatDecimal(settingsStore.dailyLimit))")
            } onDecrement: {
                if settingsStore.dailyLimit > 0 {
                    settingsStore.dailyLimit -= 1
                    UIAccessibility.post(notification: .announcement, argument: "Daily limit set to \(Formatter.formatDecimal(settingsStore.dailyLimit))")
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Daily drink limit")
            .accessibilityValue("\(Formatter.formatDecimal(settingsStore.dailyLimit)) drinks")
            .accessibilityHint("Use increment and decrement to adjust daily limit")
            
            Stepper {
                Text("Weekly limit: \(Formatter.formatDecimal(settingsStore.weeklyLimit))")
            } onIncrement: {
                settingsStore.weeklyLimit += 1
                UIAccessibility.post(notification: .announcement, argument: "Weekly limit set to \(Formatter.formatDecimal(settingsStore.weeklyLimit))")
            } onDecrement: {
                if settingsStore.weeklyLimit > 0 {
                    settingsStore.weeklyLimit -= 1
                    UIAccessibility.post(notification: .announcement, argument: "Weekly limit set to \(Formatter.formatDecimal(settingsStore.weeklyLimit))")
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Weekly drink limit")
            .accessibilityValue("\(Formatter.formatDecimal(settingsStore.weeklyLimit)) drinks")
            .accessibilityHint("Use increment and decrement to adjust weekly limit")
            
            Button {
                showResetLongestStreakConfirmation = true
            } label: {
                Text("Reset longest streak")
            }
            .accessibilityLabel("Reset longest streak")
            .accessibilityHint("Warning: This will reset your longest streak record to zero")
            
            Button {
                showResetHealingProgressConfirmation = true
            } label: {
                Text("Reset brain healing progress")
            }
            .accessibilityLabel("Reset brain healing progress")
            .accessibilityHint("Warning: This will reset your brain healing progress to day zero")
        } header: {
            Text("Limits & Progress")
        } footer: {
            Text("Brain healing progress: \(Int(settingsStore.healingMomentumDays)) days")
        }
    }
    
    private var measurementDefaultsSection: some View {
        Section("Measurement defaults") {
            Picker("Volume Measurement", selection: Binding(
                get: { settingsStore.useMetricAsDefault },
                set: { newValue in
                    settingsStore.useMetricAsDefault = newValue
                }
            )) {
                Text("oz").tag(false)
                    .accessibilityLabel("Ounces as default volume unit")
                Text("ml").tag(true)
                    .accessibilityLabel("Milliliters as default volume unit")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Default volume measurement")
            .accessibilityHint("Choose default unit for volume measurements")
            
            Picker("Alcohol Strength", selection: Binding(
                get: { settingsStore.useProofAsDefault },
                set: { newValue in
                    settingsStore.useProofAsDefault = newValue
                }
            )) {
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
    
    private var drinkingStatusSection: some View {
        Section("Drinking Status Tracking") {
            Toggle("Track drinking status", isOn: Binding(
                get: { settingsStore.drinkingStatusTrackingEnabled },
                set: { settingsStore.drinkingStatusTrackingEnabled = $0 }
            ))
            .accessibilityLabel("Enable drinking status tracking")
            .accessibilityHint("Enables or disables calculation of drinking status based on CDC guidelines")
            
            if settingsStore.drinkingStatusTrackingEnabled {
                DatePicker(
                    "Start tracking from",
                    selection: Binding(
                        get: { settingsStore.drinkingStatusStartDate },
                        set: { settingsStore.drinkingStatusStartDate = $0 }
                    ),
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .accessibilityLabel("Tracking start date")
                .accessibilityHint("Sets the date from which drinking status will be calculated")
                
                Picker("Sex (for CDC guidelines)", selection: Binding(
                    get: { settingsStore.userSex },
                    set: { settingsStore.userSex = $0 }
                )) {
                    ForEach(Sex.allCases, id: \.self) { sex in
                        Text(sex.rawValue).tag(sex)
                    }
                }
                .accessibilityLabel("Sex for CDC guidelines")
                .accessibilityHint("Helps apply appropriate heavy drinking thresholds based on CDC recommendations")
                
                Text("Drinking status calculated from this date forward, including alcohol-free days. Sex helps apply CDC heavy drinking thresholds (8+ drinks/week for females, 15+ for males).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Drinking status tracking explanation")
            }
        }
    }
    
    private var savingsSection: some View {
        Section("Savings Tracker") {
            Toggle("Show Savings Tracker", isOn: Binding(
                get: { settingsStore.showSavings },
                set: { settingsStore.showSavings = $0 }
            ))
            .accessibilityLabel("Show savings tracker")
            .accessibilityHint("Displays money saved during alcohol-free streaks")
            
            if settingsStore.showSavings {
                Button {
                    showMonthlySpendAlert = true
                } label: {
                    HStack {
                        Text("Monthly alcohol spending")
                        Spacer()
                        Text(SavingsCalculator.formatCurrency(settingsStore.monthlyAlcoholSpend))
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityLabel("Monthly alcohol spending")
                .accessibilityValue(SavingsCalculator.formatCurrency(settingsStore.monthlyAlcoholSpend))
                .accessibilityHint("Tap to edit monthly alcohol spending amount")
                
                Text("Used to calculate money saved during alcohol-free streaks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
            
            Button {
                showTestDataGenerationOptions = true
            } label: {
                Text("Generate Test Data")
            }
            .disabled(!drinkRecords.isEmpty)
            .accessibilityLabel("Generate test data")
            .accessibilityHint("Creates 18 months of sample drink records for testing")
            
            if !drinkRecords.isEmpty {
                Text("Clear existing data first to use test data generator")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Test data generator unavailable")
                    .accessibilityHint("Clear existing drink records first to enable test data generation")
            }
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
    
    private func generateTestData() async {
        guard drinkRecords.isEmpty else { return }
        guard let profile = selectedProfile else { return }
        
        isGeneratingData = true
        defer { isGeneratingData = false }
        
        do {
            let generator = TestDataGenerator(modelContext: modelContext, settingsStore: settingsStore)
            try await generator.generateTestData(profile: profile) { progress in
                generationProgress = progress
            }
        } catch {
            print("Failed to generate test data: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self, CustomDrink.self, UserSettings.self,
        migrationPlan: AppMigrationPlan.self,
        configurations: config
    )

    SettingsScreen()
        .modelContainer(container)
}

struct ConfirmationDialogsModifier: ViewModifier {
    @Binding var showDeleteAllDataConfirmation: Bool
    @Binding var showSyncWithHealthKitConfirmation: Bool
    @Binding var showResetLongestStreakConfirmation: Bool
    @Binding var showResetHealingProgressConfirmation: Bool
    @Binding var showTestDataGenerationOptions: Bool
    @Binding var showGenerationConfirmation: Bool
    @Binding var selectedProfile: TestDataDrinkingProfile?
    let deleteAllRecords: () -> Void
    let syncWithHealthKit: () async -> Void
    let resetLongestStreak: () -> Void
    let resetHealingProgress: () -> Void
    let generateTestData: () async -> Void
    
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
            .confirmationDialog(
                "Reset brain healing progress to zero?",
                isPresented: $showResetHealingProgressConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancel", role: .cancel) { }
                    .accessibilityLabel("Cancel reset")
                    .accessibilityHint("Cancels resetting brain healing progress")
                
                Button("Reset") {
                    resetHealingProgress()
                }
                .accessibilityLabel("Confirm reset")
                .accessibilityHint("Resets your brain healing progress to day zero")
            } message: {
                Text("This will reset your brain healing momentum to day zero and return you to the initial recovery phase.")
            }
            .confirmationDialog(
                "Choose drinking profile for test data generation",
                isPresented: $showTestDataGenerationOptions,
                titleVisibility: .visible
            ) {
                ForEach(TestDataDrinkingProfile.allCases, id: \.self) { profile in
                    Button("\(profile.rawValue) (\(profile.description))") {
                        selectedProfile = profile
                        showGenerationConfirmation = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .confirmationDialog(
                "Generate 18 months of \(selectedProfile?.rawValue ?? "") test data?",
                isPresented: $showGenerationConfirmation,
                titleVisibility: .visible
            ) {
                Button("Generate Test Data") {
                    Task { await generateTestData() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will create approximately 540 drink records. Only use for testing purposes.")
            }
    }
}
