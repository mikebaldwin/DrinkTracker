//
//  SettingsScreenWatch.swift
//  Watch
//
//  Created by Mike Baldwin on 7/9/24.
//

import SwiftData
import SwiftUI

struct SettingsScreenWatch: View {
    @AppStorage("dailyTarget") private var dailyTarget = 0.0
    @AppStorage("weeklyTarget") private var weeklyTarget = 0.0
    @AppStorage("longestStreak") private var longestStreak = 0

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper {
                        Text("Daily target: \(Formatter.formatDecimal(dailyTarget))")
                            .font(.body)
                    } onIncrement: {
                        dailyTarget += 1
                    } onDecrement: {
                        if dailyTarget > 0 {
                            dailyTarget -= 1
                        }
                    }
                    Stepper {
                        Text("Weekly target: \(Formatter.formatDecimal(weeklyTarget))")
                            .font(.body)
                    } onIncrement: {
                        weeklyTarget += 1
                    } onDecrement: {
                        if weeklyTarget > 0 {
                            weeklyTarget -= 1
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
