//
//  AppSchemaV5.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 10/15/25.
//

import Foundation
import SwiftData

// MARK: - Schema V5 (With Goal Property)
enum AppSchemaV5: VersionedSchema {
    static var versionIdentifier = Schema.Version(5, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            DrinkRecord.self,
            CustomDrink.self,
            UserSettings.self
        ]
    }
}

extension AppSchemaV5 {
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
        var goal: Goal? = Goal.abstinence

        // Brain healing properties - NO TOGGLE NEEDED
        var healingMomentumDays: Double = 0.0
        var lastHealingUpdate: Date = Date()
        var lastHealingReset: Date = Date()
        var healingPhaseRawValue: String = HealingPhase.criticalRecovery.rawValue

        // Computed property for enum
        var healingPhase: HealingPhase {
            get { HealingPhase(rawValue: healingPhaseRawValue) ?? .criticalRecovery }
            set { healingPhaseRawValue = newValue.rawValue }
        }

        init() {}
    }

    @Model
    final class DrinkRecord: Identifiable {
        var id = UUID().uuidString
        var standardDrinks: Double = 0.0
        var timestamp = Date()

        init(standardDrinks: Double, date: Date = Date()) {
            self.standardDrinks = standardDrinks
            self.timestamp = date
        }

        init(_ customDrink: CustomDrink) {
            self.standardDrinks = customDrink.standardDrinks
        }

        static func thisWeeksDrinksPredicate() -> Predicate<DrinkRecord> {
            let startOfCurrentWeek = Date.startOfWeek

            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp >= startOfCurrentWeek
            }
        }

        static func todaysDrinksPredicate() -> Predicate<DrinkRecord> {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            let tomorrow = Date.tomorrow
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp < tomorrow && drinkRecord.timestamp >= startOfToday
            }
        }
    }

    @Model
    final class CustomDrink {
        var name: String = ""
        var standardDrinks: Double = 0.0

        init(name: String, standardDrinks: Double) {
            self.name = name
            self.standardDrinks = standardDrinks
        }
    }
}
