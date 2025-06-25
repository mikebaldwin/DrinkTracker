//
//  AppSchemaV1.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import Foundation
import SwiftData

// MARK: - Schema V1 (Original)
enum AppSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            DrinkRecord.self,
            CustomDrink.self,
            UserSettings.self
        ]
    }
}
