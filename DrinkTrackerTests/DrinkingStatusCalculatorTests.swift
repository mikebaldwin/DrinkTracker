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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(status == .heavyDrinker)
    }
    
    // MARK: - Tracking Period Tests
    
    
    @Test("Insufficient tracking period returns nil") func testInsufficientTrackingPeriod() throws {
        let settingsStore = try createTestSettingsStore()
        // Set start date to 3 days ago, but requesting 7-day period
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 5.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
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
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        // 8.5 drinks/week = heavy for female
        #expect(status == .heavyDrinker)
    }
    
    // MARK: - Average Drinks Per Day Tests

    @Test("Calculate average drinks per day for 7-day period") 
    func testAverageDrinksPerDaySevenDays() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        // 14 drinks over 7 days = 2.0 drinks/day
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 3.0),
            createDrinkRecord(daysAgo: 2, standardDrinks: 2.0), 
            createDrinkRecord(daysAgo: 3, standardDrinks: 3.0),
            createDrinkRecord(daysAgo: 4, standardDrinks: 2.0),
            createDrinkRecord(daysAgo: 5, standardDrinks: 2.0),
            createDrinkRecord(daysAgo: 6, standardDrinks: 2.0)
        ]
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .week7,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(average == 2.0) // 14 drinks ÷ 7 days = 2.0 drinks/day
    }

    @Test("Calculate average drinks per day for 30-day period") 
    func testAverageDrinksPerDayThirtyDays() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date()
        
        // Create drinks spread across 30 days totaling 60 drinks = 2.0 drinks/day
        let drinks = Array(1...20).map { i in
            createDrinkRecord(daysAgo: i, standardDrinks: 3.0)  // 20 x 3 = 60 drinks total
        }
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .days30,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(average == 2.0) // 60 drinks ÷ 30 days = 2.0 drinks/day
    }

    @Test("Calculate average drinks per day for year period") 
    func testAverageDrinksPerDayYear() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -400, to: Date()) ?? Date()
        
        // Create drinks spread across year totaling 729 drinks ≈ 2.0 drinks/day
        let simpleDrinks = Array(1...243).map { i in
            createDrinkRecord(daysAgo: i % 300, standardDrinks: 3.0)  // 243 * 3 = 729 ≈ 730
        }
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .year,
            drinks: simpleDrinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        let expectedAverage = 729.0 / 365.0 // ≈ 1.997 drinks/day
        #expect(abs(average! - expectedAverage) < 0.01)
    }


    @Test("Average per day returns nil for insufficient tracking period") 
    func testAveragePerDayReturnsNilForInsufficientPeriod() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 2.0)]
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .week7,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(average == nil)
    }

    @Test("Zero drinks shows zero average per day") 
    func testZeroDrinksShowsZeroAveragePerDay() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        let drinks: [DrinkRecord] = []
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .week7,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(average == 0.0)
    }

    @Test("Fractional drinks per day calculation") 
    func testFractionalDrinksPerDay() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        // 5 drinks over 7 days = ~0.714 drinks/day
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 2.5),
            createDrinkRecord(daysAgo: 4, standardDrinks: 2.5)
        ]
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .week7,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        let expectedAverage = 5.0 / 7.0 // ~0.714
        #expect(abs(average! - expectedAverage) < 0.001)
    }

    @Test("Different periods with same drinks show different averages") 
    func testDifferentPeriodsShowDifferentAverages() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -400, to: Date()) ?? Date()
        
        // Same total drinks but different period lengths
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 1.0),
            createDrinkRecord(daysAgo: 15, standardDrinks: 1.0),
            createDrinkRecord(daysAgo: 100, standardDrinks: 1.0)
        ]
        
        let weekAverage = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .week7, drinks: drinks, trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        let monthAverage = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .days30, drinks: drinks, trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        let yearAverage = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .year, drinks: drinks, trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        // Week period: 1 drink ÷ 7 days = ~0.143 drinks/day
        #expect(abs(weekAverage! - (1.0/7.0)) < 0.001)
        // Month period: 2 drinks ÷ 30 days = ~0.067 drinks/day  
        #expect(abs(monthAverage! - (2.0/30.0)) < 0.001)
        // Year period: 3 drinks ÷ 365 days = ~0.008 drinks/day
        #expect(abs(yearAverage! - (3.0/365.0)) < 0.001)
    }

    @Test("Multiple drinks on same day counted correctly") 
    func testMultipleDrinksSameDayCountedCorrectly() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        // 3 drinks all on same day = 3 total drinks over 7 days
        let drinks = [
            createDrinkRecord(daysAgo: 1, standardDrinks: 1.0),
            createDrinkRecord(daysAgo: 1, standardDrinks: 1.5),
            createDrinkRecord(daysAgo: 1, standardDrinks: 0.5)
        ]
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .week7,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        let expectedAverage = 3.0 / 7.0 // ~0.429 drinks/day
        #expect(abs(average! - expectedAverage) < 0.001)
    }
    
    // MARK: - Bug Fix Tests
    
    @Test("Bug fix: 0.4 drinks per day over 30 days should be light drinker")
    func testBugFixPointFourDrinksPerDayThirtyDays() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date()
        
        // 0.4 drinks per day over 30 days = 12 drinks total = 2.8 drinks per week
        // This should be classified as light drinker (0.0-3.0 drinks/week)
        let drinks = Array(1...12).map { i in
            createDrinkRecord(daysAgo: i * 2, standardDrinks: 1.0)
        }
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .days30,
            drinks: drinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(status == .lightDrinker)
        
        // Also verify the average calculation
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: .days30,
            drinks: drinks,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(abs(average! - 0.4) < 0.001)
    }
    
    @Test("Boundary test: very small positive drinks per week")
    func testVerySmallPositiveDrinksPerWeek() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        // 0.1 drinks per week (very small positive amount)
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 0.1)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(status == .lightDrinker)
    }
    
    @Test("Boundary test: exactly 3.0 drinks per week edge case")
    func testExactlyThreePointZeroDrinksPerWeek() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        
        // Exactly 3.0 drinks per week
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 3.0)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(status == .lightDrinker)
    }
    
    @Test("Boundary test: just over 3.0 drinks per week")
    func testJustOverThreeDrinksPerWeek() throws {
        let settingsStore = try createTestSettingsStore()
        settingsStore.drinkingStatusStartDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        settingsStore.userSex = .male
        
        // 3.1 drinks per week should be moderate
        let drinks = [createDrinkRecord(daysAgo: 1, standardDrinks: 3.1)]
        
        let status = DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: drinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
        
        #expect(status == .moderateDrinker)
    }
}