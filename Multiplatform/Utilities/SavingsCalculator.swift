//
//  SavingsCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/28/25.
//

import Foundation

struct SavingsCalculator {
    static func calculateSavings(
        currentStreak: Int,
        monthlySpend: Double
    ) -> Double {
        guard monthlySpend > 0 else { return 0.0 }
        
        let averageDaysPerMonth = 30.42
        let dailySpend = monthlySpend / averageDaysPerMonth
        
        return dailySpend * Double(currentStreak)
    }
    
    static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}