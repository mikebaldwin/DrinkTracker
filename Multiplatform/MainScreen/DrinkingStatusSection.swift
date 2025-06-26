//
//  DrinkingStatusSection.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import SwiftUI
import SwiftData

struct DrinkingStatusSection: View {
    let drinkRecords: [DrinkRecord]
    @Environment(SettingsStore.self) private var settingsStore
    
    var body: some View {
        Section("Drinking Status") {
            ForEach(ReportingPeriod.allCases, id: \.self) { period in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(period.rawValue)
                            .fontWeight(.medium)
                        Spacer()
                        if let status = DrinkingStatusCalculator.calculateStatus(
                            for: period,
                            drinks: drinkRecords,
                            settingsStore: settingsStore
                        ) {
                            Text(status.rawValue)
                                .foregroundStyle(colorForStatus(status))
                        } else {
                            Text("Not enough data")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
                        for: period,
                        drinks: drinkRecords,
                        settingsStore: settingsStore
                    ) {
                        HStack {
                            Text("Average: \(Formatter.formatDecimal(average)) drinks per day")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabel(for: period))
            }
        }
    }
    
    private func accessibilityLabel(for period: ReportingPeriod) -> String {
        let status = DrinkingStatusCalculator.calculateStatus(
            for: period,
            drinks: drinkRecords,
            settingsStore: settingsStore
        )
        
        let average = DrinkingStatusCalculator.calculateAverageDrinksPerDay(
            for: period,
            drinks: drinkRecords,
            settingsStore: settingsStore
        )
        
        var label = "\(period.rawValue): "
        
        if let status = status {
            label += "\(status.rawValue)"
        } else {
            label += "Not enough data"
        }
        
        if let average = average {
            let drinkWord = average == 1.0 ? "drink" : "drinks"
            label += ", Average \(Formatter.formatDecimal(average)) \(drinkWord) per day"
        }
        
        return label
    }
    
    private func colorForStatus(_ status: DrinkingStatus) -> Color {
        switch status {
        case .nonDrinker, .lightDrinker: return .green
        case .moderateDrinker: return .orange
        case .heavyDrinker: return .red
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self, CustomDrink.self, UserSettings.self,
        migrationPlan: AppMigrationPlan.self,
        configurations: config
    )
    let context = ModelContext(container)
    let settingsStore = SettingsStore(modelContext: context)
    
    // Add sample drinks to show clear daily averages
    let calendar = Calendar.current
    let now = Date()
    let sampleDrinks = [
        // Recent week: 7 drinks total = 1.0 drinks/day
        DrinkRecord(standardDrinks: 2.0, date: calendar.date(byAdding: .day, value: -1, to: now) ?? now),
        DrinkRecord(standardDrinks: 1.5, date: calendar.date(byAdding: .day, value: -3, to: now) ?? now),
        DrinkRecord(standardDrinks: 2.0, date: calendar.date(byAdding: .day, value: -5, to: now) ?? now),
        DrinkRecord(standardDrinks: 1.5, date: calendar.date(byAdding: .day, value: -6, to: now) ?? now),
        
        // Within 30 days: additional 15 drinks = 22 total ÷ 30 = ~0.73 drinks/day
        DrinkRecord(standardDrinks: 3.0, date: calendar.date(byAdding: .day, value: -15, to: now) ?? now),
        DrinkRecord(standardDrinks: 2.0, date: calendar.date(byAdding: .day, value: -20, to: now) ?? now),
        DrinkRecord(standardDrinks: 2.5, date: calendar.date(byAdding: .day, value: -25, to: now) ?? now),
        DrinkRecord(standardDrinks: 7.5, date: calendar.date(byAdding: .day, value: -28, to: now) ?? now),
        
        // Within year: many more drinks for lower daily average
        DrinkRecord(standardDrinks: 4.0, date: calendar.date(byAdding: .day, value: -60, to: now) ?? now),
        DrinkRecord(standardDrinks: 3.0, date: calendar.date(byAdding: .day, value: -120, to: now) ?? now),
        DrinkRecord(standardDrinks: 5.0, date: calendar.date(byAdding: .day, value: -200, to: now) ?? now)
    ]
    
    Form {
        DrinkingStatusSection(drinkRecords: sampleDrinks)
    }
    .environment(settingsStore)
}
