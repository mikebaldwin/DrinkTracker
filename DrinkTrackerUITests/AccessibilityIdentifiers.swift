//
//  AccessibilityIdentifiers.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 2/4/26.
//

import Foundation

/// Centralized accessibility identifiers for UI testing.
/// Use these constants in both the app code and UI tests to ensure consistency.
public enum AccessibilityIdentifiers {

    // MARK: - Main Screen
    public enum MainScreen {
        public static let calculatorButton = "mainScreen.calculatorButton"
        public static let customDrinksButton = "mainScreen.customDrinksButton"
        public static let quickEntryButton = "mainScreen.quickEntryButton"
        public static let currentStreakLabel = "mainScreen.currentStreakLabel"
        public static let longestStreakLabel = "mainScreen.longestStreakLabel"
        public static let drinksThisWeekLabel = "mainScreen.drinksThisWeekLabel"
        public static let drinksTodayLabel = "mainScreen.drinksTodayLabel"
        public static let remainingDrinksLabel = "mainScreen.remainingDrinksLabel"
        public static let drinkingStatusBadge = "mainScreen.drinkingStatusBadge"
        public static let healingProgressView = "mainScreen.healingProgressView"
        public static let weeklyChart = "mainScreen.weeklyChart"
        public static let settingsButton = "mainScreen.settingsButton"
    }

    // MARK: - Settings Screen
    public enum Settings {
        public static let screen = "settings.screen"
        public static let dailyLimitField = "settings.dailyLimitField"
        public static let weeklyLimitField = "settings.weeklyLimitField"
        public static let drinkingStatusToggle = "settings.drinkingStatusToggle"
        public static let drinkingStatusStartDatePicker = "settings.drinkingStatusStartDatePicker"
        public static let userSexPicker = "settings.userSexPicker"
        public static let metricToggle = "settings.metricToggle"
        public static let proofToggle = "settings.proofToggle"
        public static let showSavingsToggle = "settings.showSavingsToggle"
        public static let monthlySpendField = "settings.monthlySpendField"
        public static let goalPicker = "settings.goalPicker"
        public static let syncHealthKitButton = "settings.syncHealthKitButton"
        public static let generateTestDataButton = "settings.generateTestDataButton"
        public static let deleteAllDataButton = "settings.deleteAllDataButton"
    }

    // MARK: - Drinks History Screen
    public enum History {
        public static let screen = "history.screen"
        public static let drinksList = "history.drinksList"
        public static let emptyStateMessage = "history.emptyStateMessage"

        public static func drinkRow(_ id: String) -> String {
            "history.drinkRow.\(id)"
        }

        public static func deleteButton(_ id: String) -> String {
            "history.deleteButton.\(id)"
        }

        public static func editButton(_ id: String) -> String {
            "history.editButton.\(id)"
        }
    }

    // MARK: - Calculator Screen
    public enum Calculator {
        public static let screen = "calculator.screen"
        public static let totalStandardDrinksLabel = "calculator.totalStandardDrinksLabel"
        public static let addIngredientButton = "calculator.addIngredientButton"
        public static let cancelButton = "calculator.cancelButton"
        public static let doneButton = "calculator.doneButton"
        
        public static func ingredientSection(_ index: Int) -> String {
            "calculator.ingredient.\(index)"
        }
        
        public static func ingredientVolumeField(_ index: Int) -> String {
            "calculator.ingredient.\(index).volumeField"
        }
        
        public static func ingredientVolumePicker(_ index: Int) -> String {
            "calculator.ingredient.\(index).volumePicker"
        }
        
        public static func ingredientStrengthField(_ index: Int) -> String {
            "calculator.ingredient.\(index).strengthField"
        }
        
        public static func ingredientStrengthPicker(_ index: Int) -> String {
            "calculator.ingredient.\(index).strengthPicker"
        }
        
        public static func ingredientTotalLabel(_ index: Int) -> String {
            "calculator.ingredient.\(index).totalLabel"
        }
    }
    
    // MARK: - Custom Drink Entry
    public enum CustomDrinkEntry {
        public static let screen = "customDrink.screen"
        public static let nameField = "customDrink.nameField"
        public static let totalVolumeField = "customDrink.totalVolumeField"
        public static let volumeUnitPicker = "customDrink.volumeUnitPicker"
        public static let addIngredientButton = "customDrink.addIngredientButton"
        public static let saveButton = "customDrink.saveButton"
        public static let cancelButton = "customDrink.cancelButton"

        public static func ingredientRow(_ index: Int) -> String {
            "customDrink.ingredient.\(index)"
        }

        public static func ingredientVolumeField(_ index: Int) -> String {
            "customDrink.ingredient.\(index).volumeField"
        }

        public static func ingredientABVField(_ index: Int) -> String {
            "customDrink.ingredient.\(index).abvField"
        }

        public static func ingredientDeleteButton(_ index: Int) -> String {
            "customDrink.ingredient.\(index).deleteButton"
        }
    }

    // MARK: - Quick Entry
    public enum QuickEntry {
        public static let view = "quickEntry.view"
        public static let closeButton = "quickEntry.closeButton"

        public static func drinkButton(_ name: String) -> String {
            "quickEntry.drink.\(name)"
        }
    }

    // MARK: - Navigation
    public enum Navigation {
        public static let mainTab = "navigation.mainTab"
        public static let historyTab = "navigation.historyTab"
        public static let settingsTab = "navigation.settingsTab"
    }

    // MARK: - Alerts & Dialogs
    public enum Alert {
        public static let deleteConfirmation = "alert.deleteConfirmation"
        public static let deleteConfirmButton = "alert.deleteConfirmButton"
        public static let cancelButton = "alert.cancelButton"
    }
}
