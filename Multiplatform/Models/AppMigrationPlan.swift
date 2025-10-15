//
//  AppMigrationPlan.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import Foundation
import SwiftData
import OSLog

// MARK: - Migration Plan
enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            AppSchemaV1.self,
            AppSchemaV2.self,
            AppSchemaV3.self,
            AppSchemaV4.self,
            AppSchemaV5.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3,
            migrateV3toV4,
            migrateV4toV5
        ]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: AppSchemaV1.self,
        toVersion: AppSchemaV2.self,
//        willMigrate: { context in
//            Logger.settings.info("Starting migration from UserSettings V1 to V2...")
//            
//            // Fetch all V1 UserSettings
//            let descriptor = FetchDescriptor<AppSchemaV1.UserSettings>()
//            let v1SettingsCount = try context.fetchCount(descriptor)
//            Logger.settings.info("Found \(v1SettingsCount) V1 UserSettings records to migrate")
//            
//            // The automatic migration will handle copying existing properties
//            // We just log for debugging purposes
//        },
//        didMigrate: { context in
//            Logger.settings.info("Completing migration from UserSettings V1 to V2...")
//            
//            // Fetch all migrated V2 UserSettings
//            let descriptor = FetchDescriptor<AppSchemaV2.UserSettings>()
//            let v2Settings = try context.fetch(descriptor)
//            
//            Logger.settings.info("Setting default values for new properties in \(v2Settings.count) records")
//            
//            // Ensure new properties have proper default values
//            for setting in v2Settings {
//                // These should already be set by the default values in the model,
//                // but we explicitly set them to be certain
//                setting.drinkingStatusTrackingEnabled = true
//                setting.drinkingStatusStartDate = Date()
//                setting.userSex = Sex.female
//            }
//            
//            // Save the context to persist changes
//            try context.save()
//            
//            Logger.settings.info("Migration from UserSettings V1 to V2 completed successfully")
//        }
    )
    
    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: AppSchemaV2.self,
        toVersion: AppSchemaV3.self
    )
    
    static let migrateV3toV4 = MigrationStage.lightweight(
        fromVersion: AppSchemaV3.self,
        toVersion: AppSchemaV4.self
    )

    static let migrateV4toV5 = MigrationStage.lightweight(
        fromVersion: AppSchemaV4.self,
        toVersion: AppSchemaV5.self
    )
}
