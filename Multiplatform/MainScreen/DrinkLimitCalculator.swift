//
//  DrinkLimitCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation

struct DrinkLimitCalculator {
    static func remainingDrinksToday(
        dailyLimit: Double?,
        weeklyLimit: Double?,
        totalToday: Double,
        totalThisWeek: Double
    ) -> Double {
        guard let dailyLimit else { return 0 }
        
        var remaining = dailyLimit - totalToday
        
        if let weeklyLimit {
            let remainingForWeek = weeklyLimit - totalThisWeek
            if remaining >= remainingForWeek {
                remaining = totalToday == 0 ? 0 : remainingForWeek
            }
        }
        
        return remaining
    }
}