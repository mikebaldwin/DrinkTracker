//
//  Formatter.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import Foundation

struct Formatter {
    static func formatDecimal(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal

        return formatter.string(from: number as NSNumber) ?? "0"
    }

    static func formatStreakDuration(_ days: Int) -> String {
        guard days >= 90 else {
            let dayText = days == 1 ? "day" : "days"
            return "\(days) \(dayText)"
        }

        let months = days / 30
        let remainingDays = days % 30

        let monthText = months == 1 ? "month" : "months"

        if remainingDays == 0 {
            return "\(months) \(monthText)"
        } else {
            let dayText = remainingDays == 1 ? "day" : "days"
            return "\(months) \(monthText), \(remainingDays) \(dayText)"
        }
    }
}
