//
//  WeeklyProgressStatusTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 12/9/25.
//

@testable import DrinkTracker
import Testing
import Foundation

@Suite("WeeklyProgressStatus Tests")
struct WeeklyProgressStatusTests {

    // MARK: - Below Limit Tests

    @Test("Below limit with decimal value preserves precision") func testBelowLimitDecimalPrecision() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 3.5)

        #expect(status.displayText == "10.5 drinks below limit")
    }

    @Test("Below limit with whole number displays without decimal") func testBelowLimitWholeNumber() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 4.0)

        #expect(status.displayText == "10 drinks below limit")
    }

    @Test("Below limit with exactly 1 drink uses singular") func testBelowLimitSingular() {
        let status = WeeklyProgressStatus(weeklyLimit: 5.0, totalThisWeek: 4.0)

        #expect(status.displayText == "1 drink below limit")
    }

    @Test("Below limit with 0.5 drinks shows decimal") func testBelowLimitHalfDrink() {
        let status = WeeklyProgressStatus(weeklyLimit: 5.0, totalThisWeek: 4.5)

        #expect(status.displayText == "0.5 drinks below limit")
    }

    @Test("Below limit with 1.5 drinks shows decimal and plural") func testBelowLimitOneAndHalf() {
        let status = WeeklyProgressStatus(weeklyLimit: 5.0, totalThisWeek: 3.5)

        #expect(status.displayText == "1.5 drinks below limit")
    }

    @Test("Below limit color is success green") func testBelowLimitColor() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 3.5)

        #expect(status.color == .successGreen)
    }

    // MARK: - On Track Tests

    @Test("On track when exactly at limit") func testOnTrack() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 14.0)

        #expect(status.displayText == "On track")
    }

    @Test("On track color is success green") func testOnTrackColor() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 14.0)

        #expect(status.color == .successGreen)
    }

    // MARK: - Over Limit Tests

    @Test("Over limit with decimal value preserves precision") func testOverLimitDecimalPrecision() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 16.5)

        #expect(status.displayText == "2.5 drinks over limit")
    }

    @Test("Over limit with whole number displays without decimal") func testOverLimitWholeNumber() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 17.0)

        #expect(status.displayText == "3 drinks over limit")
    }

    @Test("Over limit with exactly 1 drink uses singular") func testOverLimitSingular() {
        let status = WeeklyProgressStatus(weeklyLimit: 5.0, totalThisWeek: 6.0)

        #expect(status.displayText == "1 drink over limit")
    }

    @Test("Over limit with 0.5 drinks shows decimal") func testOverLimitHalfDrink() {
        let status = WeeklyProgressStatus(weeklyLimit: 5.0, totalThisWeek: 5.5)

        #expect(status.displayText == "0.5 drinks over limit")
    }

    @Test("Over limit color is danger red") func testOverLimitColor() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 16.5)

        #expect(status.color == .dangerRed)
    }

    // MARK: - No Limit Set Tests

    @Test("No limit set when limit is nil") func testNoLimitSet() {
        let status = WeeklyProgressStatus(weeklyLimit: nil, totalThisWeek: 5.0)

        #expect(status.displayText == "No weekly limit set")
    }

    @Test("No limit set color is warning orange") func testNoLimitSetColor() {
        let status = WeeklyProgressStatus(weeklyLimit: nil, totalThisWeek: 5.0)

        #expect(status.color == .warningOrange)
    }

    // MARK: - Edge Cases

    @Test("Very small remaining amount") func testVerySmallRemaining() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 13.9)

        #expect(status.displayText == "0.1 drinks below limit")
    }

    @Test("Very small over amount") func testVerySmallOver() {
        let status = WeeklyProgressStatus(weeklyLimit: 14.0, totalThisWeek: 14.1)

        #expect(status.displayText == "0.1 drinks over limit")
    }

    @Test("Large remaining amount") func testLargeRemaining() {
        let status = WeeklyProgressStatus(weeklyLimit: 100.0, totalThisWeek: 12.3)

        #expect(status.displayText == "87.7 drinks below limit")
    }
}
