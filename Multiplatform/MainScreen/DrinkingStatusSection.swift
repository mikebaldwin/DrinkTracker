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
            if settingsStore.drinkingStatusTrackingEnabled {
                ForEach(ReportingPeriod.allCases, id: \.self) { period in
                    HStack {
                        Text(period.rawValue)
                        Spacer()
                        if let status = DrinkingStatusCalculator.calculateStatus(
                            for: period,
                            drinks: drinkRecords,
                            settingsStore: settingsStore
                        ) {
                            Text(status.rawValue)
                                .foregroundStyle(colorForStatus(status))
                                .accessibilityLabel("\(period.rawValue): \(status.rawValue)")
                        } else {
                            Text("Insufficient data")
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("\(period.rawValue): Insufficient data")
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            } else {
                Text("Tracking disabled")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Drinking status tracking is disabled")
            }
        }
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
    
    Form {
        DrinkingStatusSection(drinkRecords: [])
    }
    .environment(settingsStore)
}