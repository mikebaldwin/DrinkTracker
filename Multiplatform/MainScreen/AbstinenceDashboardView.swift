//
//  AbstinenceDashboardView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 12/8/25.
//

import SwiftUI
import SwiftData

struct AbstinenceDashboardView: View {
    let currentStreak: Int
    let drinkingStatus7Days: DrinkingStatus?
    let drinkingStatus30Days: DrinkingStatus?
    let drinkingStatusYear: DrinkingStatus?
    let drinkRecords: [DrinkRecord]
    let settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Current Streak")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }

            Text(Formatter.formatStreakDuration(currentStreak))
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            DrinkingStatusCardSection(
                drinkingStatus7Days: drinkingStatus7Days,
                drinkingStatus30Days: drinkingStatus30Days,
                drinkingStatusYear: drinkingStatusYear,
                drinkRecords: drinkRecords,
                settingsStore: settingsStore
            )
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel())
    }

    private func accessibilityLabel() -> String {
        var label = "Dashboard summary. "

        label += "Current streak: \(Formatter.formatStreakDuration(currentStreak)). "

        label += "Drinking status: "
        if let status7 = drinkingStatus7Days {
            label += "Last 7 days \(status7.rawValue), "
        }
        if let status30 = drinkingStatus30Days {
            label += "Last 30 days \(status30.rawValue), "
        }
        if let statusYear = drinkingStatusYear {
            label += "Last year \(statusYear.rawValue). "
        }

        return label
    }
}

#Preview {
    let sampleDrinks = [
        DrinkRecord(standardDrinks: 1.5, date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
        DrinkRecord(standardDrinks: 2.0, date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date())
    ]

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self, CustomDrink.self, UserSettings.self,
        configurations: config
    )
    let context = ModelContext(container)
    let settingsStore = SettingsStore(modelContext: context)

    AbstinenceDashboardView(
        currentStreak: 6,
        drinkingStatus7Days: .lightDrinker,
        drinkingStatus30Days: .moderateDrinker,
        drinkingStatusYear: .heavyDrinker,
        drinkRecords: sampleDrinks,
        settingsStore: settingsStore
    )
    .padding()
}
