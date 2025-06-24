//
//  SettingsScreenWatch.swift
//  Watch
//
//  Created by Mike Baldwin on 7/9/24.
//

import SwiftData
import SwiftUI

struct SettingsScreenWatch: View {
    @Environment(SettingsStore.self) private var settingsStore

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper {
                        Text("Daily limit: \(Formatter.formatDecimal(settingsStore.dailyLimit))")
                            .font(.body)
                    } onIncrement: {
                        settingsStore.dailyLimit += 1
                    } onDecrement: {
                        if settingsStore.dailyLimit > 0 {
                            settingsStore.dailyLimit -= 1
                        }
                    }
                    Stepper {
                        Text("Weekly limit: \(Formatter.formatDecimal(settingsStore.weeklyLimit))")
                            .font(.body)
                    } onIncrement: {
                        settingsStore.weeklyLimit += 1
                    } onDecrement: {
                        if settingsStore.weeklyLimit > 0 {
                            settingsStore.weeklyLimit -= 1
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
