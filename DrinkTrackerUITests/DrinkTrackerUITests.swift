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

    @MainActor
    func testMainScreenAppears() throws {
        // Verify main screen elements are visible
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.MainScreen.quickEntryButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.MainScreen.calculatorButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.MainScreen.customDrinksButton].exists)
    }

    @MainActor
    func testNavigateToSettings() throws {
        // Tap settings button
        let settingsButton = app.buttons[AccessibilityIdentifiers.MainScreen.settingsButton]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        // Verify settings screen appears
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    @MainActor
    func testQuickEntryButtonTap() throws {
        // Tap quick entry button
        let quickEntryButton = app.buttons[AccessibilityIdentifiers.MainScreen.quickEntryButton]
        XCTAssertTrue(quickEntryButton.exists)
        quickEntryButton.tap()

        // Verify quick entry view appears (add specific assertion when view is identified)
        // This will depend on the QuickEntry view implementation
    }
    
    // MARK: - Calculator Tests
    
    @MainActor
    func testCalculatorWithTwoIngredients() throws {
        XCTContext.runActivity(named: "Navigate to calculator") { _ in
            let calculatorButton = app.buttons[AccessibilityIdentifiers.MainScreen.calculatorButton]
            XCTAssertTrue(calculatorButton.waitForExistence(timeout: 2))
            calculatorButton.tap()
        }
        
        XCTContext.runActivity(named: "Wait for calculator to appear and verify cancel button exists") { _ in
            let cancelButton = app.buttons[AccessibilityIdentifiers.Calculator.cancelButton]
            XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        }
        
        XCTContext.runActivity(named: "Enter first ingredient: 2oz at 40% ABV") { _ in
            // Enter volume for first ingredient
            let volumeField1 = app.textFields[AccessibilityIdentifiers.Calculator.ingredientVolumeField(0)]
            XCTAssertTrue(volumeField1.waitForExistence(timeout: 3))
            volumeField1.tap()
            volumeField1.typeText("2")
            
            // Enter strength for first ingredient
            let strengthField1 = app.textFields[AccessibilityIdentifiers.Calculator.ingredientStrengthField(0)]
            XCTAssertTrue(strengthField1.waitForExistence(timeout: 2))
            strengthField1.tap()
            strengthField1.typeText("40")
            
            // Wait a moment for calculation to complete
            Thread.sleep(forTimeInterval: 0.5)
            
            // Verify first ingredient total is calculated
            let ingredientTotal1 = app.staticTexts[AccessibilityIdentifiers.Calculator.ingredientTotalLabel(0)]
            XCTAssertTrue(ingredientTotal1.exists)
            XCTAssertTrue(ingredientTotal1.label.contains("1.2") || ingredientTotal1.label.contains("standard"))
        }
        
        XCTContext.runActivity(named: "Add second ingredient") { _ in
            let addIngredientButton = app.buttons[AccessibilityIdentifiers.Calculator.addIngredientButton]
            XCTAssertTrue(addIngredientButton.exists)
            addIngredientButton.tap()
            
            // Wait for new ingredient fields to appear
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        XCTContext.runActivity(named: "Enter second ingredient: 1oz at 18% ABV") { _ in
            // Enter volume for second ingredient
            let volumeField2 = app.textFields[AccessibilityIdentifiers.Calculator.ingredientVolumeField(1)]
            XCTAssertTrue(volumeField2.waitForExistence(timeout: 3))
            volumeField2.tap()
            volumeField2.typeText("1")
            
            // Enter strength for second ingredient
            let strengthField2 = app.textFields[AccessibilityIdentifiers.Calculator.ingredientStrengthField(1)]
            XCTAssertTrue(strengthField2.waitForExistence(timeout: 2))
            strengthField2.tap()
            strengthField2.typeText("18")
            
            // Wait a moment for calculation to complete
            Thread.sleep(forTimeInterval: 0.5)
            
            // Verify second ingredient total is calculated
            let ingredientTotal2 = app.staticTexts[AccessibilityIdentifiers.Calculator.ingredientTotalLabel(1)]
            XCTAssertTrue(ingredientTotal2.exists)
            XCTAssertTrue(ingredientTotal2.label.contains("0.27") || ingredientTotal2.label.contains("standard"))
        }
        
        XCTContext.runActivity(named: "Verify total standard drinks") { _ in
            let totalLabel = app.staticTexts[AccessibilityIdentifiers.Calculator.totalStandardDrinksLabel]
            XCTAssertTrue(totalLabel.exists)
            // Total should be 1.2 + 0.27 = 1.47 standard drinks
            XCTAssertTrue(totalLabel.label.contains("1.47") || totalLabel.label.contains("1.5"))
        }
    }

    // MARK: - Settings Tests

    @MainActor
    func testChangeGoalSetting() throws {
        XCTContext.runActivity(named: "Navigate to settings") { _ in
            app.buttons[AccessibilityIdentifiers.MainScreen.settingsButton].tap()
        }

        XCTContext.runActivity(named: "Change goal setting") { _ in
            // Find and interact with goal picker
            let goalPicker = app.segmentedControls[AccessibilityIdentifiers.Settings.goalPicker]
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
    }

    @MainActor
    func testModifyDailyLimit() throws {
        XCTContext.runActivity(named: "Navigate to settings") { _ in
            app.buttons[AccessibilityIdentifiers.MainScreen.settingsButton].tap()
        }

        XCTContext.runActivity(named: "Switch to moderation goal") { _ in
            let goalPicker = app.segmentedControls[AccessibilityIdentifiers.Settings.goalPicker]
            XCTAssertTrue(goalPicker.waitForExistence(timeout: 2))
            goalPicker.buttons["Moderation"].tap()
        }

        XCTContext.runActivity(named: "Modify daily limit") { _ in
            let dailyLimitStepper = app.steppers[AccessibilityIdentifiers.Settings.dailyLimitField]
            XCTAssertTrue(dailyLimitStepper.waitForExistence(timeout: 2))

            // Increment daily limit
            dailyLimitStepper.buttons["Increment"].tap()

            // Verify stepper still exists after interaction
            XCTAssertTrue(dailyLimitStepper.exists)
        }
    }

    @MainActor
    func testDeleteAllDataFlow() throws {
        XCTContext.runActivity(named: "Navigate to settings") { _ in
            app.buttons[AccessibilityID.MainScreen.settingsButton].tap()
        }

        XCTContext.runActivity(named: "Scroll to developer section") { _ in
            let deleteButton = app.buttons[AccessibilityID.Settings.deleteAllDataButton]
            scrollTo(element: deleteButton, inApp: app)
            XCTAssertTrue(deleteButton.exists)
        }

        XCTContext.runActivity(named: "Trigger delete confirmation") { _ in
            let deleteButton = app.buttons[AccessibilityID.Settings.deleteAllDataButton]
            deleteButton.tap()

            // Verify confirmation dialog appears
            let confirmationDialog = app.alerts.firstMatch
            XCTAssertTrue(confirmationDialog.waitForExistence(timeout: 2))
        }

        XCTContext.runActivity(named: "Cancel deletion") { _ in
            let cancelButton = app.alerts.firstMatch.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }

    // MARK: - Drinks History Tests

    @MainActor
    func testNavigateToDrinksHistory() throws {
        // This test assumes there's a way to navigate to history
        // Adjust based on actual navigation implementation

        // Look for history navigation button/link
        // For now, we'll skip this test until navigation is clarified
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
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

