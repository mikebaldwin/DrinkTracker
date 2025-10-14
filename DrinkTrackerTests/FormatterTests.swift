//
//  FormatterTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 10/14/25.
//

@testable import DrinkTracker
import Foundation
import Testing

@Suite("Formatter Tests")
struct FormatterTests {

    // MARK: - formatDecimal Tests

    @Test("formatDecimal handles whole numbers")
    func formatDecimalWholeNumbers() {
        #expect(Formatter.formatDecimal(5.0) == "5")
        #expect(Formatter.formatDecimal(10.0) == "10")
    }

    @Test("formatDecimal handles decimal numbers")
    func formatDecimalDecimals() {
        #expect(Formatter.formatDecimal(5.5) == "5.5")
        #expect(Formatter.formatDecimal(10.26) == "10.3")
    }

    @Test("formatDecimal handles zero")
    func formatDecimalZero() {
        #expect(Formatter.formatDecimal(0.0) == "0")
    }

    // MARK: - formatStreakDuration Tests - Below Threshold (< 90 days)

    @Test("formatStreakDuration handles zero days")
    func formatStreakDurationZero() {
        #expect(Formatter.formatStreakDuration(0) == "0 days")
    }

    @Test("formatStreakDuration handles one day singular")
    func formatStreakDurationOneDay() {
        #expect(Formatter.formatStreakDuration(1) == "1 day")
    }

    @Test("formatStreakDuration handles two days")
    func formatStreakDurationTwoDays() {
        #expect(Formatter.formatStreakDuration(2) == "2 days")
    }

    @Test("formatStreakDuration handles 30 days")
    func formatStreakDuration30Days() {
        #expect(Formatter.formatStreakDuration(30) == "30 days")
    }

    @Test("formatStreakDuration handles 59 days")
    func formatStreakDuration59Days() {
        #expect(Formatter.formatStreakDuration(59) == "59 days")
    }

    @Test("formatStreakDuration handles 89 days - edge case before threshold")
    func formatStreakDuration89Days() {
        #expect(Formatter.formatStreakDuration(89) == "89 days")
    }

    // MARK: - formatStreakDuration Tests - At/Above Threshold (>= 90 days)

    @Test("formatStreakDuration handles 90 days - threshold")
    func formatStreakDuration90Days() {
        // 90 days = 3 months exactly
        #expect(Formatter.formatStreakDuration(90) == "3 months")
    }

    @Test("formatStreakDuration handles 91 days")
    func formatStreakDuration91Days() {
        // 91 days = 3 months, 1 day
        #expect(Formatter.formatStreakDuration(91) == "3 months, 1 day")
    }

    @Test("formatStreakDuration handles 92 days")
    func formatStreakDuration92Days() {
        // 92 days = 3 months, 2 days
        #expect(Formatter.formatStreakDuration(92) == "3 months, 2 days")
    }

    @Test("formatStreakDuration handles 120 days")
    func formatStreakDuration120Days() {
        // 120 days = 4 months exactly
        #expect(Formatter.formatStreakDuration(120) == "4 months")
    }

    @Test("formatStreakDuration handles 150 days")
    func formatStreakDuration150Days() {
        // 150 days = 5 months
        #expect(Formatter.formatStreakDuration(150) == "5 months")
    }

    @Test("formatStreakDuration handles 180 days")
    func formatStreakDuration180Days() {
        // 180 days = 6 months exactly
        #expect(Formatter.formatStreakDuration(180) == "6 months")
    }

    @Test("formatStreakDuration handles 365 days - one year")
    func formatStreakDuration365Days() {
        // 365 days = 12 months, 5 days
        #expect(Formatter.formatStreakDuration(365) == "12 months, 5 days")
    }

    @Test("formatStreakDuration handles 730 days - two years")
    func formatStreakDuration730Days() {
        // 730 days = 24 months, 10 days
        #expect(Formatter.formatStreakDuration(730) == "24 months, 10 days")
    }

    // MARK: - Singular/Plural Edge Cases

    @Test("formatStreakDuration handles 30 days - exactly 1 month singular")
    func formatStreakDuration30DaysAsOneMonth() {
        // 30 days = 1 month (should use singular)
        // But this is below threshold, so shows as "30 days"
        #expect(Formatter.formatStreakDuration(30) == "30 days")
    }

    @Test("formatStreakDuration handles 60 days")
    func formatStreakDuration60Days() {
        // 60 days = 2 months exactly (below threshold)
        #expect(Formatter.formatStreakDuration(60) == "60 days")
    }

    @Test("formatStreakDuration handles 61 days - with 1 remaining day singular")
    func formatStreakDuration61Days() {
        // 61 days = 2 months, 1 day (singular day, below threshold)
        #expect(Formatter.formatStreakDuration(61) == "61 days")
    }

    // MARK: - Brain Healing Phase Alignment Tests

    @Test("formatStreakDuration at 90 days aligns with Neuroplasticity to Cognitive Recovery transition")
    func formatStreakDurationBrainHealingPhaseTransition() {
        // 90 days marks the transition from Neuroplasticity Boost to Cognitive Recovery
        // Should switch to months display at this milestone
        #expect(Formatter.formatStreakDuration(89) == "89 days")
        #expect(Formatter.formatStreakDuration(90) == "3 months")
        #expect(Formatter.formatStreakDuration(91) == "3 months, 1 day")
    }

    @Test("formatStreakDuration handles 100 days")
    func formatStreakDuration100Days() {
        // 100 days = 3 months, 10 days
        #expect(Formatter.formatStreakDuration(100) == "3 months, 10 days")
    }

    @Test("formatStreakDuration handles 200 days")
    func formatStreakDuration200Days() {
        // 200 days = 6 months, 20 days
        #expect(Formatter.formatStreakDuration(200) == "6 months, 20 days")
    }
}
