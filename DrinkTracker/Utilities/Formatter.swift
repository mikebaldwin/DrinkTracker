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
}
