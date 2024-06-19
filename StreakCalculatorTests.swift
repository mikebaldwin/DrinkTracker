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
        
        #expect(streak == 5)
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
        
        #expect(streak == 1)
    }

}
