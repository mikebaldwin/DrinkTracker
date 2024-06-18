//
//  ContentView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Charts
import HealthKitUI
import SwiftData
import SwiftUI

struct MainScreen: View {
    @AppStorage("dailyTarget") private var dailyTarget: Double?
    @AppStorage("weeklyTarget") private var weeklyTarget: Double?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) private var allDrinks: [DrinkRecord]
    
    @Query(
        filter: DrinkRecord.thisWeeksDrinksPredicate(),
        sort: [SortDescriptor(\DrinkRecord.timestamp)]
    ) private var thisWeeksDrinks: [DrinkRecord]
    
    @State private var showQuickEntryView = false
    @State private var showCalculatorView = false
    @State private var showCustomDrinksView = false
    @State private var showSettingsScreen = false
    
    private var healthStoreManager = HealthStoreManager.shared
    
    private var totalStandardDrinksToday: Double {
        thisWeeksDrinks
            .filter { Calendar.current.isDateInToday($0.timestamp) }
            .reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    private var totalStandardDrinksThisWeek: Double {
        thisWeeksDrinks.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Drinks") {
                    ChartView(
                        drinkRecords: thisWeeksDrinks,
                        totalStandardDrinksToday: totalStandardDrinksToday,
                        totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
                    )
                }
                if dailyTarget != nil || weeklyTarget != nil {
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
                        HStack {
                            Text("Alcohol-free days")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(calculateCurrentStreak()) day streak")
                        }
                    }
                }
                Section {
                    Button {
                        showCalculatorView = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Drink Calculator")
                        }
                    }
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettingsScreen = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showQuickEntryView) {
            QuickEntryView { drinkRecord in
                recordDrink(drinkRecord)
                showQuickEntryView = false
            }
            .presentationDetents([.fraction(0.2)])
        }
        .sheet(isPresented: $showCalculatorView) {
            CalculatorScreen(createCustomDrink: { customDrink in
                addCustomDrink(customDrink)
            }, createDrinkRecord: { drinkRecord in
                recordDrink(drinkRecord)
            })
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showCustomDrinksView) {
            CustomDrinkScreen(modelContext: modelContext) {
                recordDrink(DrinkRecord($0))
            }
        }
        .sheet(isPresented: $showSettingsScreen) {
            SettingsScreen()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                _ = thisWeeksDrinks
            }
        }
    }
    
    private func addCustomDrink(_ customDrink: CustomDrink) {
        modelContext.insert(customDrink)
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
    }
    
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        // grab the date of the most recent drink in drinkRecords
        guard let mostRecentDrink = allDrinks.first else { return 0 }
        
        // if date is today, set streak number to zero
        guard mostRecentDrink.timestamp < calendar.startOfDay(for: Date()) else {
            return 0
        }
        
        // otherwise...
        // Use that date as the start date of your loop
        // use Start of day tomorrow as the end date
        var iteratorDate = calendar.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: mostRecentDrink.timestamp
            )!
        )
        let startOfTomorrow = calendar.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Date()
            )!
        )

        // while loop through days between start and end
        // increment streak number until you finish
        var streak = 0
        
        while iteratorDate < startOfTomorrow {
            iteratorDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: iteratorDate
            )!
            streak += 1
        }
        
        return streak
    }
}

//#Preview {
//    MainScreen()
//        .modelContainer(previewContainer)
//}
