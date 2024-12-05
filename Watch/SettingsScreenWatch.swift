//
//  SettingsScreenWatch.swift
//  Watch
//
//  Created by Mike Baldwin on 7/9/24.
//

import SwiftData
import SwiftUI

struct SettingsScreenWatch: View {
    @AppStorage("dailyTarget") private var dailyLimit = 0.0
    @AppStorage("weeklyTarget") private var weeklyLimit = 0.0
    @AppStorage("longestStreak") private var longestStreak = 0

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper {
                        Text("Daily limit: \(Formatter.formatDecimal(dailyLimit))")
                            .font(.body)
                    } onIncrement: {
                        dailyLimit += 1
                    } onDecrement: {
                        if dailyLimit > 0 {
                            dailyLimit -= 1
                        }
                    }
                    Stepper {
                        Text("Weekly limit: \(Formatter.formatDecimal(weeklyLimit))")
                            .font(.body)
                    } onIncrement: {
                        weeklyLimit += 1
                    } onDecrement: {
                        if weeklyLimit > 0 {
                            weeklyLimit -= 1
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsScreenWatch()
}
