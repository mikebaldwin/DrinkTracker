//
//  ContentView.swift
//  DrinkTrackerWatch Watch App
//
//  Created by Mike Baldwin on 6/21/24.
//

import HealthKitUI
import SwiftData
import SwiftUI
import OSLog

struct ContentView: View {
    @Environment(SettingsStore.self) private var settingsStore
    
    private var dailyLimit: Double? {
        settingsStore.dailyLimit > 0 ? settingsStore.dailyLimit : nil
    }
    
    private var weeklyLimit: Double? {
        settingsStore.weeklyLimit > 0 ? settingsStore.weeklyLimit : nil
    }
    
    private var longestStreak: Int {
        settingsStore.longestStreak
    }

    @Environment(\.modelContext) private var modelContext

    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) private var allDrinks: [DrinkRecord]
    
    @State private var currentStreak = 0
    @State private var showCustomDrinksView = false
    @State private var showQuickEntryView = false
    
    private var healthStoreManager = HealthStoreManager.shared

    private var thisWeeksDrinks: [DrinkRecord] {
        allDrinks.filter {
            $0.timestamp >= Date.startOfWeek
        }
    }
    private var todaysDrinks: [DrinkRecord] {
        allDrinks.filter {
            $0.timestamp < Date.tomorrow && $0.timestamp >= Date.startOfToday
        }
    }
    private var totalStandardDrinksToday: Double {
        todaysDrinks.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    private var totalStandardDrinksThisWeek: Double {
        thisWeeksDrinks.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    private var remainingDrinksToday: Double {
        guard let dailyLimit else { return 0 }
        
        var remaining = dailyLimit - totalStandardDrinksToday
        
        if let weeklyLimit {
            let remainingForWeek = weeklyLimit - totalStandardDrinksThisWeek
            if remaining >= remainingForWeek {
                remaining = remainingForWeek
            }
        }
        
        return remaining
    }

    var body: some View {
        NavigationStack {
            Form {
                actionsSection
                if dailyLimit != nil || weeklyLimit != nil {
                    limitsSection
                }
                streaksSection
                historySection
            }
            .padding()
            .sheet(isPresented: $showQuickEntryView) {
                QuickEntryViewWatch { drinkRecord in
                    recordDrink(drinkRecord)
                }
            }
            .sheet(isPresented: $showCustomDrinksView) {
                CustomDrinkScreen() {
                    recordDrink(DrinkRecord($0))
                }
            }
        }
    }
    
    private var historySection: some View {
        Section {
            NavigationLink {
                DrinksHistoryScreenWatch()
            } label: {
                Text("Drinks History")
            }
            NavigationLink {
                SettingsScreenWatch()
            } label: {
                Text("Settings")
            }
        }
    }
    
    private var limitsSection: some View {
        Section("Limits") {
            if let dailyLimit {
                HStack {
                    Text("Today")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if remainingDrinksToday > 0 {
                        let noun = remainingDrinksToday == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(remainingDrinksToday)) \(noun) below limit")
                    } else if remainingDrinksToday == 0 {
                        Text("Daily limit reached!")
                    } else {
                        let drinksOverLimit = remainingDrinksToday * -1
                        let noun = drinksOverLimit == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(drinksOverLimit)) \(noun) over limit")
                            .foregroundStyle(Color(.red))
                            .fontWeight(.semibold)
                    }
                }
            }
            if let weeklyLimit {
                HStack {
                    Text("This week")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    let remainingDrinks = weeklyLimit - totalStandardDrinksThisWeek
                    if remainingDrinks < weeklyLimit {
                        let noun = remainingDrinks == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(remainingDrinks)) \(noun) below limit")
                    } else if remainingDrinks == weeklyLimit {
                        Text("Weekly limit reached!")
                    } else {
                        let drinksOverLimit = remainingDrinks * -1
                        let noun = drinksOverLimit == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(drinksOverLimit)) \(noun) over limit")
                            .foregroundStyle(Color(.red))
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private var streaksSection: some View {
        Section("Alcohol-free Days") {
            HStack {
                Text("Current streak")
                    .fontWeight(.semibold)
                Spacer()
                Text("\($currentStreak.wrappedValue) days")
            }
            HStack {
                Text("Longest streak")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(settingsStore.longestStreak) days")
            }
        }
    }
    
    private var actionsSection: some View {
        Section("Record a Drink") {
            Button {
                showCustomDrinksView = true
            } label: {
                HStack {
                    Image(systemName: "wineglass")
                    Text("Custom Drinks")
                }
            }
            Button {
                showQuickEntryView = true
            } label: {
                HStack {
                    Image(systemName: "bolt")
                    Text("Quick Entry")
                }
            }
        }
    }
    
    private func recordDrink(_ drink: DrinkRecord) {
        Task {
            do {
                let sample = HKQuantitySample(
                    type: HKQuantityType(.numberOfAlcoholicBeverages),
                    quantity: HKQuantity(
                        unit: HKUnit.count(),
                        doubleValue: drink.standardDrinks
                    ),
                    start: drink.timestamp,
                    end: drink.timestamp
                )
                
                try await healthStoreManager.save(sample)
                Logger.watchApp.info("Drink saved to HealthKit successfully")
                
                drink.id = sample.uuid.uuidString
            } catch {
                Logger.watchApp.error("Failed to save drink to HealthKit: \(error.localizedDescription)")
            }
        }
        modelContext.insert(drink)
        refreshCurrentStreak()
    }
    
    private func refreshCurrentStreak() {
        guard let drink = allDrinks.first else { return }
                
        currentStreak = StreakCalculator().calculateCurrentStreak(drink)
        
        if currentStreak == 0 && settingsStore.longestStreak == 1 {
            // prevents giving streak credit user has gone zero days without alcohol
            settingsStore.longestStreak = 0
        }
        if currentStreak > settingsStore.longestStreak {
            settingsStore.longestStreak = currentStreak
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self,
        configurations: config
    )

    ContentView()
        .modelContainer(container)
}
