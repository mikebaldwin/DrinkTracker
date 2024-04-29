//
//  SettingsScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import SwiftUI

struct SettingsScreen: View {
    @AppStorage("dailyTarget") private var dailyTarget = 1
    @AppStorage("weeklyTarget") private var weeklyTarget = 14
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Stepper {
                        Text("Daily target: \(dailyTarget)")
                    } onIncrement: {
                        dailyTarget += 1
                    } onDecrement: {
                        if dailyTarget < 0 {
                            dailyTarget -= 1
                        }
                    }
                    Stepper {
                        Text("Weekly target: \(weeklyTarget)")
                    } onIncrement: {
                        weeklyTarget += 1
                    } onDecrement: {
                        if weeklyTarget < 0 {
                            weeklyTarget -= 1
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
}