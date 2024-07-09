//
//  ContentView.swift
//  DrinkTrackerWatch Watch App
//
//  Created by Mike Baldwin on 6/21/24.
//

import HealthKitUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("dailyTarget") private var dailyTarget: Double?
    @AppStorage("weeklyTarget") private var weeklyTarget: Double?
    @AppStorage("longestStreak") private var longestStreak = 0

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

    var body: some View {
        NavigationStack {
            Form {
                actionsSection
                if dailyTarget != nil || weeklyTarget != nil {
                    targetsSection
                }
                streaksSection
                historySection
            }
            .padding()
            .sheet(isPresented: $showQuickEntryView) {
                QuickEntryView { drinkRecord in
                    recordDrink(drinkRecord)
                    showQuickEntryView = false
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
    
    private var targetsSection: some View {
        Section("Targets") {
            if let dailyTarget {
                HStack {
                    Text("Today")
                        .fontWeight(.semibold)
                    Spacer()
                    if totalStandardDrinksToday < dailyTarget {
                        let drinksRemaining = dailyTarget - totalStandardDrinksToday
                        let noun = drinksRemaining > 1 ? "drinks" : "drink"
                        Text("\(Formatter.formatDecimal(drinksRemaining)) \(noun) below target")
                    } else if totalStandardDrinksToday == dailyTarget {
                        Text("Daily target reached!")
                    } else {
                        let drinksOverTarget = totalStandardDrinksToday - dailyTarget
                        let noun = drinksOverTarget > 1 ? "drinks" : "drink"
                        Text("\(Formatter.formatDecimal(drinksOverTarget)) \(noun) above target")
                            .foregroundStyle(Color(.red))
                            .fontWeight(.semibold)
                    }
                }
            }
            if let weeklyTarget {
                HStack {
                    Text("This week")
                        .fontWeight(.semibold)
                    Spacer()
                    if totalStandardDrinksThisWeek < weeklyTarget {
                        Text("\(Formatter.formatDecimal(weeklyTarget - totalStandardDrinksThisWeek)) drinks below target")
                    } else if totalStandardDrinksThisWeek == weeklyTarget {
                        Text("Daily target reached!")
                    } else {
                        Text("\(Formatter.formatDecimal(totalStandardDrinksThisWeek - weeklyTarget)) drinks above target")
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
                Text("\(longestStreak) days")
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
                debugPrint("✅ Drink saved to HealthKit on \(drink.timestamp)")
                
                drink.id = sample.uuid.uuidString
            } catch {
                debugPrint("🛑 Failed to save drink to HealthKit: \(error.localizedDescription)")
            }
        }
        modelContext.insert(drink)
        refreshCurrentStreak()
    }
    
    private func refreshCurrentStreak() {
        guard let drink = allDrinks.first else { return }
                
        currentStreak = StreakCalculator().calculateCurrentStreak(drink)
        
        if currentStreak == 0 && longestStreak == 1 {
            // prevents giving streak credit user has gone zero days without alcohol
            longestStreak = 0
        }
        if currentStreak > longestStreak {
            longestStreak = currentStreak
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
