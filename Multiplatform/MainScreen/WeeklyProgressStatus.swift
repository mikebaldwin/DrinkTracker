//
//  WeeklyProgressStatus.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 12/8/25.
//

import SwiftUI

enum WeeklyProgressStatus {
    case belowLimit(Double)
    case onTrack
    case overLimit(Double)
    case noLimitSet

    init(weeklyLimit: Double?, totalThisWeek: Double) {
        guard let weeklyLimit = weeklyLimit else {
            self = .noLimitSet
            return
        }

        let remaining = weeklyLimit - totalThisWeek

        if remaining > 1 {
            self = .belowLimit(remaining)
        } else if remaining > 0 {
            self = .belowLimit(remaining)
        } else if remaining == 0 {
            self = .onTrack
        } else if remaining >= -1 {
            self = .overLimit(abs(remaining))
        } else {
            self = .overLimit(abs(remaining))
        }
    }

    var displayText: String {
        switch self {
        case .belowLimit(let remaining):
            let formatted = Formatter.formatDecimal(remaining)
            let noun = remaining == 1.0 ? "drink" : "drinks"
            return "\(formatted) \(noun) below limit"
        case .onTrack:
            return "On track"
        case .overLimit(let over):
            let formatted = Formatter.formatDecimal(over)
            let noun = over == 1.0 ? "drink" : "drinks"
            return "\(formatted) \(noun) over limit"
        case .noLimitSet:
            return "No weekly limit set"
        }
    }

    var color: Color {
        switch self {
        case .belowLimit, .onTrack:
            return .successGreen
        case .overLimit:
            return .dangerRed
        case .noLimitSet:
            return .warningOrange
        }
    }
}
