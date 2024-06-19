//
//  StreakCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/18/24.
//

import Foundation

struct StreakCalculator {
    func calculateCurrentStreak(_ drink: DrinkRecord) -> Int {
        let calendar = Calendar.current
        
        // if date is today, set streak number to zero
        guard drink.timestamp < calendar.startOfDay(for: Date()) else {
            return 0
        }
        
        // otherwise...
        // Use that date as the start date of your loop
        // use Start of day tomorrow as the end date
        var iteratorDate = calendar.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: drink.timestamp
            )!
        )
        let startOfTomorrow = calendar.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Date()
            )!
        )

        // while loop through days between start and end
        // increment streak number until you finish
        var streak = 0
        
        while iteratorDate < startOfTomorrow {
            iteratorDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: iteratorDate
            )!
            streak += 1
        }
        
        return streak
    }
}
