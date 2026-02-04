//
//  AccessibilityIdentifiers.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 2/4/26.
//

import Foundation

/// Centralized accessibility identifiers for UI testing.
/// Use these constants in both the app code and UI tests to ensure consistency.
enum AccessibilityIdentifiers {

    // MARK: - Main Screen
    enum MainScreen {
        static let calculatorButton = "mainScreen.calculatorButton"
        static let customDrinksButton = "mainScreen.customDrinksButton"
        static let quickEntryButton = "mainScreen.quickEntryButton"
        static let currentStreakLabel = "mainScreen.currentStreakLabel"
        static let longestStreakLabel = "mainScreen.longestStreakLabel"
        static let drinksThisWeekLabel = "mainScreen.drinksThisWeekLabel"
        static let drinksTodayLabel = "mainScreen.drinksTodayLabel"
        static let remainingDrinksLabel = "mainScreen.remainingDrinksLabel"
        static let drinkingStatusBadge = "mainScreen.drinkingStatusBadge"
        static let healingProgressView = "mainScreen.healingProgressView"
        static let weeklyChart = "mainScreen.weeklyChart"
        static let settingsButton = "mainScreen.settingsButton"
    }

    // MARK: - Settings Screen
    enum Settings {
        static let screen = "settings.screen"
        static let dailyLimitField = "settings.dailyLimitField"
        static let weeklyLimitField = "settings.weeklyLimitField"
        static let drinkingStatusToggle = "settings.drinkingStatusToggle"
        static let drinkingStatusStartDatePicker = "settings.drinkingStatusStartDatePicker"
        static let userSexPicker = "settings.userSexPicker"
        static let metricToggle = "settings.metricToggle"
        static let proofToggle = "settings.proofToggle"
        static let showSavingsToggle = "settings.showSavingsToggle"
        static let monthlySpendField = "settings.monthlySpendField"
        static let goalPicker = "settings.goalPicker"
        static let syncHealthKitButton = "settings.syncHealthKitButton"
        static let generateTestDataButton = "settings.generateTestDataButton"
        static let deleteAllDataButton = "settings.deleteAllDataButton"
    }

    // MARK: - Drinks History Screen
    enum History {
        static let screen = "history.screen"
        static let drinksList = "history.drinksList"
        static let emptyStateMessage = "history.emptyStateMessage"

        static func drinkRow(_ id: String) -> String {
            "history.drinkRow.\(id)"
        }

        static func deleteButton(_ id: String) -> String {
            "history.deleteButton.\(id)"
        }

        static func editButton(_ id: String) -> String {
            "history.editButton.\(id)"
        }
    }

    // MARK: - Custom Drink Entry
    enum CustomDrinkEntry {
        static let screen = "customDrink.screen"
        static let nameField = "customDrink.nameField"
        static let totalVolumeField = "customDrink.totalVolumeField"
        static let volumeUnitPicker = "customDrink.volumeUnitPicker"
        static let addIngredientButton = "customDrink.addIngredientButton"
        static let saveButton = "customDrink.saveButton"
        static let cancelButton = "customDrink.cancelButton"

        static func ingredientRow(_ index: Int) -> String {
            "customDrink.ingredient.\(index)"
        }

        static func ingredientVolumeField(_ index: Int) -> String {
            "customDrink.ingredient.\(index).volumeField"
        }

        static func ingredientABVField(_ index: Int) -> String {
            "customDrink.ingredient.\(index).abvField"
        }

        static func ingredientDeleteButton(_ index: Int) -> String {
            "customDrink.ingredient.\(index).deleteButton"
        }
    }

    // MARK: - Quick Entry
    enum QuickEntry {
        static let view = "quickEntry.view"
        static let closeButton = "quickEntry.closeButton"

        static func drinkButton(_ name: String) -> String {
            "quickEntry.drink.\(name)"
        }
    }

    // MARK: - Navigation
    enum Navigation {
        static let mainTab = "navigation.mainTab"
        static let historyTab = "navigation.historyTab"
        static let settingsTab = "navigation.settingsTab"
    }

    // MARK: - Alerts & Dialogs
    enum Alert {
        static let deleteConfirmation = "alert.deleteConfirmation"
        static let deleteConfirmButton = "alert.deleteConfirmButton"
        static let cancelButton = "alert.cancelButton"
    }
}
