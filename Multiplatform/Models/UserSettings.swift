//
//  UserSettings.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/9/24.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    var dailyLimit: Double = 0.0
    var weeklyLimit: Double = 0.0
    var longestStreak: Int = 0
    var useMetricAsDefault: Bool = false
    var useProofAsDefault: Bool = false
    
    init() {}
}
