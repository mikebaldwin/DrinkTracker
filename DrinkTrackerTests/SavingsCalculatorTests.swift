//
//  SavingsCalculatorTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 6/28/25.
//

@testable import DrinkTracker
import Testing

@Suite("SavingsCalculator Tests")
struct SavingsCalculatorTests {
    
    @Test("Calculate savings with zero streak") 
    func testZeroStreak() {
        let savings = SavingsCalculator.calculateSavings(currentStreak: 0, monthlySpend: 100.0)
        #expect(savings == 0.0)
    }
    
    @Test("Calculate savings with zero monthly spend") 
    func testZeroMonthlySpend() {
        let savings = SavingsCalculator.calculateSavings(currentStreak: 10, monthlySpend: 0.0)
        #expect(savings == 0.0)
    }
    
    @Test("Calculate savings for 30-day streak with $100 monthly spend") 
    func testThirtyDayStreak() {
        let savings = SavingsCalculator.calculateSavings(currentStreak: 30, monthlySpend: 100.0)
        let expected = (100.0 / 30.42) * 30.0
        #expect(abs(savings - expected) < 0.01)
    }
    
    @Test("Calculate savings for 15-day streak with $150 monthly spend") 
    func testFifteenDayStreak() {
        let savings = SavingsCalculator.calculateSavings(currentStreak: 15, monthlySpend: 150.0)
        let expected = (150.0 / 30.42) * 15.0
        #expect(abs(savings - expected) < 0.01)
    }
    
    @Test("Calculate savings for 1-day streak") 
    func testOneDayStreak() {
        let savings = SavingsCalculator.calculateSavings(currentStreak: 1, monthlySpend: 60.0)
        let expected = 60.0 / 30.42
        #expect(abs(savings - expected) < 0.01)
    }
    
    @Test("Format currency for positive amount") 
    func testFormatCurrencyPositive() {
        let formatted = SavingsCalculator.formatCurrency(123.45)
        #expect(formatted.contains("123"))
        #expect(formatted.contains("45"))
    }
    
    @Test("Format currency for zero amount") 
    func testFormatCurrencyZero() {
        let formatted = SavingsCalculator.formatCurrency(0.0)
        #expect(formatted.contains("0"))
    }
    
    @Test("Format currency for small amount") 
    func testFormatCurrencySmall() {
        let formatted = SavingsCalculator.formatCurrency(5.99)
        #expect(formatted.contains("5"))
        #expect(formatted.contains("99"))
    }
}