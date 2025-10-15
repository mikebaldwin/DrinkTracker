//
//  SettingsManager.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/24/25.
//

import Foundation
import Observation
import OSLog
import SwiftData

@Observable
final class SettingsStore {
    private(set) var settings: UserSettings
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        Logger.settings.info("Initializing SettingsStore")
        let descriptor = FetchDescriptor<UserSettings>()
        
        do {
            let existingSettings = try modelContext.fetch(descriptor)
            
            if let foundSettings = existingSettings.first {
                self.settings = foundSettings
                Logger.settings.info("Existing UserSettings found, initialization complete")
                verifyMigration()
            } else {
                Logger.settings.info("No existing settings found, creating new UserSettings")
                
                // Create new settings and trigger migration
                let newSettings = UserSettings()
                modelContext.insert(newSettings)
                
                // Migrate from UserDefaults if this is the first time
                Logger.settings.info("Triggering migration from UserDefaults")
                SettingsMigrator.migrateFromUserDefaults(to: newSettings)
                
                try modelContext.save()
                self.settings = newSettings
                Logger.settings.info("Successfully created and saved new UserSettings")
            }
        } catch {
            Logger.settings.error("Error fetching or creating UserSettings: \(error.localizedDescription)")
            
            // Create default settings on error
            let defaultSettings = UserSettings()
            modelContext.insert(defaultSettings)
            self.settings = defaultSettings
            Logger.settings.info("Created fallback UserSettings due to error")
        }
    }
    
    func updateSettings(_ updates: (UserSettings) -> Void) {
        updates(settings)
        do {
            try modelContext.save()
            Logger.settings.debug("Settings updated and saved successfully")
        } catch {
            Logger.settings.error("Failed to save settings: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Computed Properties for Cleaner Access
    
    var dailyLimit: Double {
        get { settings.dailyLimit }
        set { updateSettings { $0.dailyLimit = newValue } }
    }
    
    var weeklyLimit: Double {
        get { settings.weeklyLimit }
        set { updateSettings { $0.weeklyLimit = newValue } }
    }
    
    var longestStreak: Int {
        get { settings.longestStreak }
        set { updateSettings { $0.longestStreak = newValue } }
    }
    
    var useMetricAsDefault: Bool {
        get { settings.useMetricAsDefault }
        set { updateSettings { $0.useMetricAsDefault = newValue } }
    }
    
    var useProofAsDefault: Bool {
        get { settings.useProofAsDefault }
        set { updateSettings { $0.useProofAsDefault = newValue } }
    }
    
    var drinkingStatusTrackingEnabled: Bool {
        get { settings.drinkingStatusTrackingEnabled }
        set { updateSettings { $0.drinkingStatusTrackingEnabled = newValue } }
    }
    
    var drinkingStatusStartDate: Date {
        get { settings.drinkingStatusStartDate }
        set { updateSettings { $0.drinkingStatusStartDate = newValue } }
    }
    
    var userSex: Sex {
        get { settings.userSex ?? Sex.female }
        set { updateSettings { $0.userSex = newValue } }
    }
    
    var showSavings: Bool {
        get { settings.showSavings }
        set { updateSettings { $0.showSavings = newValue } }
    }
    
    var monthlyAlcoholSpend: Double {
        get { settings.monthlyAlcoholSpend }
        set { updateSettings { $0.monthlyAlcoholSpend = newValue } }
    }

    var goal: Goal {
        get { settings.goal ?? .abstinence }
        set { updateSettings { $0.goal = newValue } }
    }

    // MARK: - Brain Healing Properties (Always Enabled)
    
    var healingMomentumDays: Double {
        get { settings.healingMomentumDays }
        set { updateSettings { $0.healingMomentumDays = newValue } }
    }

    var lastHealingUpdate: Date {
        get { settings.lastHealingUpdate }
        set { updateSettings { $0.lastHealingUpdate = newValue } }
    }

    var lastHealingReset: Date {
        get { settings.lastHealingReset }
        set { updateSettings { $0.lastHealingReset = newValue } }
    }

    var healingPhase: HealingPhase {
        get { settings.healingPhase }
        set { updateSettings { $0.healingPhase = newValue } }
    }
    
    // MARK: - Brain Healing Methods
    
    // Always update healing momentum - no conditional logic
    func updateHealingMomentum(with drinkRecords: [DrinkRecord]) {
        let (newMomentum, newPhase) = HealingMomentumCalculator.updateHealingMomentum(
            drinkRecords: drinkRecords,
            settings: settings
        )
        
        updateSettings { settings in
            settings.healingMomentumDays = newMomentum
            settings.healingPhase = newPhase
            settings.lastHealingUpdate = Date()
            
            // Update reset date if momentum was reset to 0
            if newMomentum == 0 && self.settings.healingMomentumDays > 0 {
                settings.lastHealingReset = Date()
            }
        }
    }

    func resetHealingProgress() {
        updateSettings { settings in
            settings.healingMomentumDays = 0.0
            settings.healingPhase = .criticalRecovery
            settings.lastHealingReset = Date()
            settings.lastHealingUpdate = Date()
        }
    }

    // Always initialize healing momentum on app start
    func initializeHealingMomentumIfNeeded(with drinkRecords: [DrinkRecord]) {
        // Only initialize if healing momentum is at zero and we haven't set a reset date recently
        guard settings.healingMomentumDays == 0.0 && 
              Calendar.current.isDate(settings.lastHealingReset, inSameDayAs: Date()) else {
            return
        }
        
        // Use StreakCalculator to get the exact same day count as streak feature
        let sortedDrinks = drinkRecords.sorted { $0.timestamp > $1.timestamp }
        guard let mostRecentDrink = sortedDrinks.first else {
            // No drinks ever recorded - set healing to start from a long time ago
            updateSettings { settings in
                settings.lastHealingReset = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
                settings.lastHealingUpdate = Date()
                settings.healingMomentumDays = 365.0 // 1 year of healing
                settings.healingPhase = .establishedSobriety
            }
            return
        }
        
        // Use StreakCalculator to get exact same count as streak feature
        let streakCalculator = StreakCalculator()
        let currentStreakDays = streakCalculator.calculateCurrentStreak(mostRecentDrink)
        
        if currentStreakDays > 0 {
            let streakStartDate = Calendar.current.date(byAdding: .day, value: 1, to: mostRecentDrink.timestamp) ?? Date()
            
            updateSettings { settings in
                settings.lastHealingReset = streakStartDate
                settings.lastHealingUpdate = Date()
                settings.healingMomentumDays = Double(currentStreakDays)
                
                // Determine initial phase based on streak length
                if currentStreakDays <= 30 {
                    settings.healingPhase = .criticalRecovery
                } else if currentStreakDays <= 90 {
                    settings.healingPhase = .sensitiveRecovery
                } else {
                    settings.healingPhase = .establishedSobriety
                }
            }
        }
    }

    
    // MARK: - Migration Verification
    
    private func verifyMigration() {
        Logger.settings.info("Verifying migration - Current settings:")
        Logger.settings.info("  - drinkingStatusTrackingEnabled: \(self.settings.drinkingStatusTrackingEnabled)")
        Logger.settings.info("  - drinkingStatusStartDate: \(self.settings.drinkingStatusStartDate)")
        Logger.settings.info("  - userSex: \(self.settings.userSex?.rawValue ?? "nil")")
    }
}
