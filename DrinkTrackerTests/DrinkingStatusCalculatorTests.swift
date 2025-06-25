//
//  DrinkingStatusCalculatorTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 6/25/25.
//

@testable import DrinkTracker
import Testing
import Foundation
import SwiftData

@Suite("DrinkingStatusCalculator Tests")
struct DrinkingStatusCalculatorTests {
    
    // MARK: - Test Data Helpers
    
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: DrinkRecord.self, CustomDrink.self, UserSettings.self,
            configurations: config
        )
    }
    
    private func createTestSettingsStore() throws -> SettingsStore {
        let container = try createTestContainer()
        let context = ModelContext(container)
        return SettingsStore(modelContext: context)
    }
    
    private func createDrinkRecord(daysAgo: Int, standardDrinks: Double) -> DrinkRecord {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return DrinkRecord(standardDrinks: standardDrinks, date: date)
    }
    
    // MARK: - Classification Tests
    
    @Test("Non-drinker classification") func testNonDrinkerClassification() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        let drinks: [DrinkRecord] = []
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .nonDrinker)
    }
    
    @Test("Light drinker classification") func testLightDrinkerClassification() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        // 3 drinks total over 7 days = 3 drinks/week
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 1.0),
            createDrinkRecord(daysAgo: 3, standardDrinks: 1.0),
            createDrinkRecord(daysAgo: 5, standardDrinks: 1.0)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .lightDrinker)
    }
    
    @Test("Moderate drinker classification for female") func testModerateDrinkerFemale() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .female
        // 5 drinks/week = moderate for female (between 3.1 and 7.9)
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 2.5),
            createDrinkRecord(daysAgo: 4, standardDrinks: 2.5)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .moderateDrinker)
    }
    
    @Test("Moderate drinker classification for male") func testModerateDrinkerMale() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .male
        // 10 drinks/week = moderate for male (between 3.1 and 14.9)
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 5.0),
            createDrinkRecord(daysAgo: 4, standardDrinks: 5.0)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .moderateDrinker)
    }
    
    @Test("Heavy drinker classification for female") func testHeavyDrinkerFemale() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .female
        // 8+ drinks/week = heavy for female
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 4.0),
            createDrinkRecord(daysAgo: 3, standardDrinks: 4.5)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .heavyDrinker)
    }
    
    @Test("Heavy drinker classification for male") func testHeavyDrinkerMale() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .male
        // 15+ drinks/week = heavy for male
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 8.0),
            createDrinkRecord(daysAgo: 3, standardDrinks: 7.5)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .heavyDrinker)
    }
    
    @Test("Boundary test: exactly 3 drinks per week") func testExactlyThreeDrinksPerWeek() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 3.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .lightDrinker)
    }
    
    @Test("Boundary test: exactly 8 drinks per week for female") func testExactlyEightDrinksFemale() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .female
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 8.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .heavyDrinker)
    }
    
    @Test("Boundary test: exactly 15 drinks per week for male") func testExactlyFifteenDrinksMale() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .male
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 15.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .heavyDrinker)
    }
    
    // MARK: - Tracking Period Tests
    
    @Test("Tracking disabled returns nil") func testTrackingDisabled() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.drinkingStatusTrackingEnabled = false
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 5.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == nil)
    }
    
    @Test("Insufficient tracking period returns nil") func testInsufficientTrackingPeriod() throws {
        let settingsStore = try createTestSettingsStore()
        // Set start date to 3 days ago, but requesting 7-day period
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 5.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == nil)
    }
    
    @Test("Drinks before tracking start date are ignored") func testDrinksBeforeTrackingIgnored() throws {
        let settingsStore = try createTestSettingsStore()
        // Start tracking 10 days ago
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 1.0),   // Within tracking period
            createDrinkRecord(daysAgo: 15, standardDrinks: 10.0), // Before tracking started - should be ignored
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        // Should be light drinker (1 drink/week), not heavy (11 drinks/week)
        #expect(status == .lightDrinker)
    }
    
    // MARK: - Period Length Tests
    
    @Test("30-day period calculation") func testThirtyDayPeriod() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.userSex = .female
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date()
        
        // 16 drinks over 30 days = ~3.7 drinks/week = moderate
        let drinks = Array(1...16).map { i in
            createDrinkRecord(daysAgo: i * 2, standardDrinks: 1.0)
        }
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .days30,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .moderateDrinker)
    }
    
    @Test("Year period calculation") func testYearPeriod() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.userSex = .male
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -400, to: Date()) ?? Date()
        
        // 520 drinks over 365 days = ~10 drinks/week = moderate for male
        let drinks = Array(1...520).map { i in
            createDrinkRecord(daysAgo: i % 300, standardDrinks: 1.0)
        }
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .year,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .moderateDrinker)
    }
    
    // MARK: - Edge Cases
    
    @Test("Fractional drinks calculation") func testFractionalDrinks() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .female
        
        // 2.9 drinks/week should be light
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 1.5),
            createDrinkRecord(daysAgo: 4, standardDrinks: 1.4)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        #expect(status == .lightDrinker)
    }
    
    @Test("Multiple drinks same day") func testMultipleDrinksSameDay() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .female
        
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 2.0),
            createDrinkRecord(daysAgo: 1, standardDrinks: 3.0),
            createDrinkRecord(daysAgo: 1, standardDrinks: 3.5)
        ]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            settingsStore: settingsStore
        )
        
        // 8.5 drinks/week = heavy for female
        #expect(status == .heavyDrinker)
    }
}