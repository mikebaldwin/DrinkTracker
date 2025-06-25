//
//  AppSchemaV2.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import Foundation
import SwiftData

// MARK: - Schema V2 (With Drinking Status Properties)
enum AppSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            DrinkRecord.self,
            CustomDrink.self,
            UserSettings.self
        ]
    }
}
