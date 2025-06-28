//
//  AppSchemaV3.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/28/25.
//

import Foundation
import SwiftData

// MARK: - Schema V3 (With Savings Tracker Properties)
enum AppSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            DrinkRecord.self,
            CustomDrink.self,
            UserSettings.self
        ]
    }
}