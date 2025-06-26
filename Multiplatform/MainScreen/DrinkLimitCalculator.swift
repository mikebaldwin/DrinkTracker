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
    
    static func weeklyProgressMessage(
        weeklyLimit: Double?,
        totalThisWeek: Double
    ) -> String {
        guard let weeklyLimit = weeklyLimit else {
            return "No weekly limit set"
        }
        
        let remaining = weeklyLimit - totalThisWeek
        
        if remaining > 1 {
            return "\(Int(remaining)) drinks below limit"
        } else if remaining > 0 {
            return "1 drink below limit"
        } else if remaining == 0 {
            return "On track"
        } else if remaining >= -1 {
            return "1 drink over limit"
        } else {
            return "\(Int(abs(remaining))) drinks over limit"
        }
    }
}