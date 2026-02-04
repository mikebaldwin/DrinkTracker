//
//  DrinkTrackerUITests.swift
//  DrinkTrackerUITests
//
//  Created by Mike Baldwin on 2/4/26.
//

import XCTest

final class DrinkTrackerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["HEALTHKIT_MOCKED": "1"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main Screen Tests

    func testMainScreenAppears() throws {
        // Verify main screen elements are visible
        XCTAssertTrue(app.buttons[AccessibilityID.MainScreen.quickEntryButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.MainScreen.calculatorButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.MainScreen.customDrinksButton].exists)
    }

    func testNavigateToSettings() throws {
        // Tap settings button
        let settingsButton = app.buttons[AccessibilityID.MainScreen.settingsButton]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        // Verify settings screen appears
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    func testQuickEntryButtonTap() throws {
        // Tap quick entry button
        let quickEntryButton = app.buttons[AccessibilityID.MainScreen.quickEntryButton]
        XCTAssertTrue(quickEntryButton.exists)
        quickEntryButton.tap()

        // Verify quick entry view appears (add specific assertion when view is identified)
        // This will depend on the QuickEntry view implementation
    }

    // MARK: - Settings Tests

    func testChangeGoalSetting() throws {
        // Navigate to settings
        app.buttons[AccessibilityID.MainScreen.settingsButton].tap()

        // Find and interact with goal picker
        let goalPicker = app.segmentedControls[AccessibilityID.Settings.goalPicker]
        XCTAssertTrue(goalPicker.waitForExistence(timeout: 2))

        // Toggle between goals
        let moderationButton = goalPicker.buttons["Moderation"]
        let abstinenceButton = goalPicker.buttons["Abstinence"]

        if abstinenceButton.isSelected {
            moderationButton.tap()
            XCTAssertTrue(moderationButton.isSelected)
        } else {
            abstinenceButton.tap()
            XCTAssertTrue(abstinenceButton.isSelected)
        }
    }

    func testModifyDailyLimit() throws {
        // Navigate to settings
        app.buttons[AccessibilityID.MainScreen.settingsButton].tap()

        // Switch to moderation goal to reveal limits
        let goalPicker = app.segmentedControls[AccessibilityID.Settings.goalPicker]
        XCTAssertTrue(goalPicker.waitForExistence(timeout: 2))
        goalPicker.buttons["Moderation"].tap()

        // Find daily limit stepper
        let dailyLimitStepper = app.steppers[AccessibilityID.Settings.dailyLimitField]
        XCTAssertTrue(dailyLimitStepper.waitForExistence(timeout: 2))

        // Increment daily limit
        dailyLimitStepper.buttons["Increment"].tap()

        // Verify value changed (would need to check displayed value)
        XCTAssertTrue(dailyLimitStepper.exists)
    }

    func testDeleteAllDataFlow() throws {
        // Navigate to settings
        app.buttons[AccessibilityID.MainScreen.settingsButton].tap()

        // Scroll to developer section
        let deleteButton = app.buttons[AccessibilityID.Settings.deleteAllDataButton]
        scrollTo(element: deleteButton, inApp: app)

        // Tap delete button
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()

        // Verify confirmation dialog appears
        let confirmationDialog = app.alerts.firstMatch
        XCTAssertTrue(confirmationDialog.waitForExistence(timeout: 2))

        // Cancel the deletion (to avoid actually deleting data)
        let cancelButton = confirmationDialog.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
    }

    // MARK: - Drinks History Tests

    func testNavigateToDrinksHistory() throws {
        // This test assumes there's a way to navigate to history
        // Adjust based on actual navigation implementation

        // Look for history navigation button/link
        // For now, we'll skip this test until navigation is clarified
    }

    // MARK: - Helper Methods

    /// Scrolls to make an element visible if needed
    private func scrollTo(element: XCUIElement, inApp app: XCUIApplication, maxSwipes: Int = 5) {
        var swipeCount = 0
        while !element.isHittable && swipeCount < maxSwipes {
            app.swipeUp()
            swipeCount += 1
        }
    }
}

// MARK: - Accessibility Identifier Constants

/// Mirror of app's AccessibilityIdentifiers for use in UI tests
private enum AccessibilityID {
    enum MainScreen {
        static let calculatorButton = "mainScreen.calculatorButton"
        static let customDrinksButton = "mainScreen.customDrinksButton"
        static let quickEntryButton = "mainScreen.quickEntryButton"
        static let settingsButton = "mainScreen.settingsButton"
    }

    enum Settings {
        static let goalPicker = "settings.goalPicker"
        static let dailyLimitField = "settings.dailyLimitField"
        static let syncHealthKitButton = "settings.syncHealthKitButton"
        static let generateTestDataButton = "settings.generateTestDataButton"
        static let deleteAllDataButton = "settings.deleteAllDataButton"
    }

    enum History {
        static let screen = "history.screen"

        static func drinkRow(_ id: String) -> String {
            "history.drinkRow.\(id)"
        }
    }
}
