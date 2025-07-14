//
//  DashboardCardView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI
import SwiftData

struct DashboardCardView: View {
    let currentStreak: Int
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
            
            Text("\(currentStreak) days")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Drinking Status")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Last 7 days:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    if let average = average7Days {
                        let unit = drinkingStatus7Days == .lightDrinker ? "per week" : "per day"
                        Text("\(Formatter.formatDecimal(average)) \(unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                    if let status = drinkingStatus7Days {
                        Text(status.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(colorForStatus(status))
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                }
                
                HStack {
                    Text("Last 30 days:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    if let average = average30Days {
                        let unit = drinkingStatus30Days == .lightDrinker ? "per week" : "per day"
                        Text("\(Formatter.formatDecimal(average)) \(unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                    if let status = drinkingStatus30Days {
                        Text(status.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(colorForStatus(status))
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                }
                
                HStack {
                    Text("Last year:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    if let average = averageYear {
                        let unit = drinkingStatusYear == .lightDrinker ? "per week" : "per day"
                        Text("\(Formatter.formatDecimal(average)) \(unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer()
                    if let status = drinkingStatusYear {
                        Text(status.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(colorForStatus(status))
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                }
            }
            
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
    
    private func colorForStatus(_ status: DrinkingStatus) -> Color {
        switch status {
        case .nonDrinker, .lightDrinker:
            return .successGreen
        case .moderateDrinker:
            return .warningOrange
        case .heavyDrinker:
            return .dangerRed
        }
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
        var label = "Dashboard summary. Current streak: \(currentStreak) days. "
        
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
    
    DashboardCardView(
        currentStreak: 6,
        drinkingStatus7Days: .lightDrinker,
        drinkingStatus30Days: .heavyDrinker,
        drinkingStatusYear: .heavyDrinker,
        weeklyProgress: "2 drinks below limit",
        drinkRecords: sampleDrinks,
        settingsStore: settingsStore
    )
    .padding()
}
