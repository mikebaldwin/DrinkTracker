//
//  WeeklyProgressStatus.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 12/8/25.
//

import SwiftUI

enum WeeklyProgressStatus {
    case belowLimit(Int)
    case onTrack
    case overLimit(Int)
    case noLimitSet

    init(weeklyLimit: Double?, totalThisWeek: Double) {
        guard let weeklyLimit = weeklyLimit else {
            self = .noLimitSet
            return
        }

        let remaining = weeklyLimit - totalThisWeek

        if remaining > 1 {
            self = .belowLimit(Int(remaining))
        } else if remaining > 0 {
            self = .belowLimit(1)
        } else if remaining == 0 {
            self = .onTrack
        } else if remaining >= -1 {
            self = .overLimit(1)
        } else {
            self = .overLimit(Int(abs(remaining)))
        }
    }

    var displayText: String {
        switch self {
        case .belowLimit(let count):
            return count == 1 ? "1 drink below limit" : "\(count) drinks below limit"
        case .onTrack:
            return "On track"
        case .overLimit(let count):
            return count == 1 ? "1 drink over limit" : "\(count) drinks over limit"
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
