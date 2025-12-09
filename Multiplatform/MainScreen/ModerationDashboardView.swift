//
//  ModerationDashboardView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 12/8/25.
//

import SwiftUI
import SwiftData

struct ModerationDashboardView: View {
    let drinkingStatus7Days: DrinkingStatus?
    let drinkingStatus30Days: DrinkingStatus?
    let drinkingStatusYear: DrinkingStatus?
    let weeklyProgress: WeeklyProgressStatus
    let drinkRecords: [DrinkRecord]
    let settingsStore: SettingsStore

    private var totalDrinksToday: Double {
        drinkRecords.todaysRecords.totalStandardDrinks
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Today's Drinks")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }

            Text(Formatter.formatDecimal(totalDrinksToday))
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

            HStack {
                Image(systemName: "target")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Weekly Progress")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }

            Text(weeklyProgress.displayText)
                .font(.headline)
                .foregroundStyle(weeklyProgress.color)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel())
    }

    private func accessibilityLabel() -> String {
        var label = "Dashboard summary. "

        label += "Today's drinks: \(Formatter.formatDecimal(totalDrinksToday)). "

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

        label += "Weekly progress: \(weeklyProgress.displayText)"

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

    ModerationDashboardView(
        drinkingStatus7Days: .lightDrinker,
        drinkingStatus30Days: .moderateDrinker,
        drinkingStatusYear: .heavyDrinker,
        weeklyProgress: .belowLimit(2),
        drinkRecords: sampleDrinks,
        settingsStore: settingsStore
    )
    .padding()
}
