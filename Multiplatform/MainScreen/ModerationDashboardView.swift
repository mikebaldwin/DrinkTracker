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
    let weeklyProgress: String
    let drinkRecords: [DrinkRecord]
    let settingsStore: SettingsStore

    private var average7Days: Double? {
        guard settingsStore.drinkingStatusTrackingEnabled else { return nil }
        if drinkingStatus7Days == .lightDrinker {
            return DrinkingStatusCalculator.calculateAverageDrinksPerWeek(
                for: .week7,
                drinks: drinkRecords,
                trackingStartDate: settingsStore.drinkingStatusStartDate
            )
        } else {
            return DrinkingStatusCalculator.calculateAverageDrinksPerDay(
                for: .week7,
                drinks: drinkRecords,
                trackingStartDate: settingsStore.drinkingStatusStartDate
            )
        }
    }

    private var average30Days: Double? {
        guard settingsStore.drinkingStatusTrackingEnabled else { return nil }
        if drinkingStatus30Days == .lightDrinker {
            return DrinkingStatusCalculator.calculateAverageDrinksPerWeek(
                for: .days30,
                drinks: drinkRecords,
                trackingStartDate: settingsStore.drinkingStatusStartDate
            )
        } else {
            return DrinkingStatusCalculator.calculateAverageDrinksPerDay(
                for: .days30,
                drinks: drinkRecords,
                trackingStartDate: settingsStore.drinkingStatusStartDate
            )
        }
    }

    private var averageYear: Double? {
        guard settingsStore.drinkingStatusTrackingEnabled else { return nil }
        if drinkingStatusYear == .lightDrinker {
            return DrinkingStatusCalculator.calculateAverageDrinksPerWeek(
                for: .year,
                drinks: drinkRecords,
                trackingStartDate: settingsStore.drinkingStatusStartDate
            )
        } else {
            return DrinkingStatusCalculator.calculateAverageDrinksPerDay(
                for: .year,
                drinks: drinkRecords,
                trackingStartDate: settingsStore.drinkingStatusStartDate
            )
        }
    }

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
                average7Days: average7Days,
                average30Days: average30Days,
                averageYear: averageYear
            )

            HStack {
                Image(systemName: "target")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Weekly Progress")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }

            Text(weeklyProgress)
                .font(.headline)
                .foregroundStyle(progressColor())
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel())
    }

    private func progressColor() -> Color {
        if weeklyProgress.contains("below limit") || weeklyProgress.contains("On track") {
            return .successGreen
        } else if weeklyProgress.contains("over") || weeklyProgress.contains("exceeded") {
            return .dangerRed
        } else {
            return .warningOrange
        }
    }

    private func accessibilityLabel() -> String {
        var label = "Dashboard summary. "

        label += "Today's drinks: \(Formatter.formatDecimal(totalDrinksToday)). "

        label += "Drinking status: "
        if let status7 = drinkingStatus7Days {
            label += "Last 7 days \(status7.rawValue)"
            if let avg = average7Days {
                let unit = status7 == .lightDrinker ? "per week" : "per day"
                label += ", \(Formatter.formatDecimal(avg)) drinks \(unit)"
            }
            label += ", "
        }
        if let status30 = drinkingStatus30Days {
            label += "Last 30 days \(status30.rawValue)"
            if let avg = average30Days {
                let unit = status30 == .lightDrinker ? "per week" : "per day"
                label += ", \(Formatter.formatDecimal(avg)) drinks \(unit)"
            }
            label += ", "
        }
        if let statusYear = drinkingStatusYear {
            label += "Last year \(statusYear.rawValue)"
            if let avg = averageYear {
                let unit = statusYear == .lightDrinker ? "per week" : "per day"
                label += ", \(Formatter.formatDecimal(avg)) drinks \(unit)"
            }
            label += ". "
        }

        label += "Weekly progress: \(weeklyProgress)"

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
        weeklyProgress: "2 drinks below limit",
        drinkRecords: sampleDrinks,
        settingsStore: settingsStore
    )
    .padding()
}
