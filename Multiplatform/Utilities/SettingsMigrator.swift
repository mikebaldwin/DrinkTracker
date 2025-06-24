//
//  SettingsMigrator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/24/25.
//

import Foundation
import OSLog

struct SettingsMigrator {
    static func migrateFromUserDefaults(to settings: UserSettings) {
        Logger.settings.info("Starting UserDefaults to SwiftData migration")
        let userDefaults = UserDefaults.standard
        
        // Check if all settings are at their defaults (indicating first launch)
        let allAtDefaults = settings.dailyLimit == 0.0 &&
        settings.weeklyLimit == 0.0 &&
        settings.longestStreak == 0 &&
        settings.useMetricAsDefault == false &&
        settings.useProofAsDefault == false
        
        guard allAtDefaults else {
            Logger.settings.info("UserSettings already configured, skipping migration")
            return
        }
        
        var migratedCount = 0
        
        // Migrate existing UserDefaults values
        if userDefaults.object(forKey: "dailyTarget") != nil {
            let value = userDefaults.double(forKey: "dailyTarget")
            settings.dailyLimit = value
            Logger.settings.debug("Migrated dailyTarget: \(value)")
            migratedCount += 1
        }
        
        if userDefaults.object(forKey: "weeklyTarget") != nil {
            let value = userDefaults.double(forKey: "weeklyTarget")
            settings.weeklyLimit = value
            Logger.settings.debug("Migrated weeklyTarget: \(value)")
            migratedCount += 1
        }
        
        if userDefaults.object(forKey: "longestStreak") != nil {
            let value = userDefaults.integer(forKey: "longestStreak")
            settings.longestStreak = value
            Logger.settings.debug("Migrated longestStreak: \(value)")
            migratedCount += 1
        }
        
        if userDefaults.object(forKey: "useMetricAsDefault") != nil {
            let value = userDefaults.bool(forKey: "useMetricAsDefault")
            settings.useMetricAsDefault = value
            Logger.settings.debug("Migrated useMetricAsDefault: \(value)")
            migratedCount += 1
        }
        
        if userDefaults.object(forKey: "useProofAsDefault") != nil {
            let value = userDefaults.bool(forKey: "useProofAsDefault")
            settings.useProofAsDefault = value
            Logger.settings.debug("Migrated useProofAsDefault: \(value)")
            migratedCount += 1
        }
        
        Logger.settings.info("Migration completed: \(migratedCount) settings migrated from UserDefaults to SwiftData")
    }
}
