//
//  UserSettings.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/9/24.
//

import Foundation
import SwiftData

// MARK: - Current Model Typealiases
typealias UserSettings = AppSchemaV4.UserSettings

extension AppSchemaV3 {
    @Model
    final class UserSettings {
        var dailyLimit: Double = 0.0
        var weeklyLimit: Double = 0.0
        var longestStreak: Int = 0
        var useMetricAsDefault: Bool = false
        var useProofAsDefault: Bool = false
        var drinkingStatusTrackingEnabled: Bool = true
        var drinkingStatusStartDate: Date = Date()
        var userSex: Sex? = Sex.female
        var showSavings: Bool = false
        var monthlyAlcoholSpend: Double = 0.0
        
        init() {}
    }
}

extension AppSchemaV2 {
    @Model
    final class UserSettings {
        var dailyLimit: Double = 0.0
        var weeklyLimit: Double = 0.0
        var longestStreak: Int = 0
        var useMetricAsDefault: Bool = false
        var useProofAsDefault: Bool = false
        var drinkingStatusTrackingEnabled: Bool = true
        var drinkingStatusStartDate: Date = Date()
        var userSex: Sex? = Sex.female
        
        init() {}
    }
}

extension AppSchemaV1 {
    @Model
    final class UserSettings {
        var dailyLimit: Double = 0.0
        var weeklyLimit: Double = 0.0
        var longestStreak: Int = 0
        var useMetricAsDefault: Bool = false
        var useProofAsDefault: Bool = false
        
        init() {}
    }
}
