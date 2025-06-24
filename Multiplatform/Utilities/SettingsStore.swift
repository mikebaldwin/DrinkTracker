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
}
