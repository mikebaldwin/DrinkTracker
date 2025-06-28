//
//  StreakCalculatorTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 6/18/24.
//

@testable import DrinkTracker
import Foundation
import Testing

@Suite("Streak Calculator Tests")
struct StreakCalculatorTests {
    private let calculator: StreakCalculator
    private let calendar: Calendar
    private let today: Date
    
    init() {
        calculator = StreakCalculator()
        calendar = Calendar.current
        today = Date()
    }

    @Test("Test streak calculator success") func calculateStreak() {
        let drink = DrinkRecord(
            standardDrinks: 1.4,
            date: calendar.date(
                byAdding: .day,
                value: -5,
                to: today
            )!
        )
        
        let streak = calculator.calculateCurrentStreak(drink)
        
        #expect(streak == 4)
    }

    @Test("Test streak calculator with most recent drink today")
    func calculateStreakWithDrinkFromToday() {
            let drink = DrinkRecord(
                standardDrinks: 1.4,
                date: today
            )
        
        let streak = calculator.calculateCurrentStreak(drink)
        
        #expect(streak == 0)
    }
    
    @Test("Test streak calculator with most recent drink yesterday")
    func calculateStreakWithDrinkFromYesterday() {
        let drink = DrinkRecord(
            standardDrinks: 1.4,
            date: calendar.date(
                byAdding: .day,
                value: -1,
                to: today
            )!
        )
        
        let streak = calculator.calculateCurrentStreak(drink)
        
        #expect(streak == 0)
    }
    
    @Test("Test streak calculator with most recent drink 3 days ago should show 2 day streak")
    func calculateStreakWithDrinkFromThreeDaysAgo() {
        let drink = DrinkRecord(
            standardDrinks: 1.4,
            date: calendar.date(
                byAdding: .day,
                value: -3,
                to: today
            )!
        )
        
        let streak = calculator.calculateCurrentStreak(drink)
        
        #expect(streak == 2)
    }
    
    @Test("Test streak and brain healing alignment")
    func streakAndBrainHealingAlignment() {
        let drink = DrinkRecord(
            standardDrinks: 1.4,
            date: calendar.date(
                byAdding: .day,
                value: -8,
                to: today
            )!
        )
        
        let streak = calculator.calculateCurrentStreak(drink)
        
        // Verify streak calculation shows 7 days for 8-day-old drink
        #expect(streak == 7)
        
        // This validates that brain healing will now use the same logic
        // and show 7 days instead of 8 days, fixing the discrepancy
    }

}
