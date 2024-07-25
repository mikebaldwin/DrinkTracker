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
    @AppStorage("longestStreak") private var longestStreak = 0
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) private var allDrinks: [DrinkRecord]
    
    @State private var currentStreak = 0
    @State private var showCalculatorView = false
    @State private var showCustomDrinksView = false
    @State private var showQuickEntryView = false
    @State private var showSettingsScreen = false
    
    private var healthStoreManager = HealthStoreManager.shared
    
    private var thisWeeksDrinks: [DrinkRecord] {
        allDrinks.filter { $0.timestamp >= Date.startOfWeek }
    }
    private var todaysDrinks: [DrinkRecord] {
        allDrinks.filter { $0.timestamp < Date.tomorrow && $0.timestamp >= Date.startOfToday }
    }
    private var totalStandardDrinksToday: Double {
        todaysDrinks.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    private var totalStandardDrinksThisWeek: Double {
        thisWeeksDrinks.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    private var remainingDrinksToday: Double {
        guard let dailyTarget else { return 0 }
        
        var remaining = dailyTarget - totalStandardDrinksToday
        
        if let weeklyTarget {
            let remainingForWeek = weeklyTarget - totalStandardDrinksThisWeek
            if remaining >= remainingForWeek {
                remaining = remainingForWeek
            }
        }
        
        return remaining
    }
    
    var body: some View {
        NavigationStack {
            Form {
                chartSection
                
                if dailyTarget != nil || weeklyTarget != nil {
                    targetsSection
                }
                
                streaksSection
                
                actionsSection
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
            CustomDrinkScreen() {
                recordDrink(DrinkRecord($0))
            }
        }
        .sheet(isPresented: $showSettingsScreen) {
            SettingsScreen()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                _ = allDrinks
                refreshCurrentStreak()
            }
        }
        .onChange(of: allDrinks) {
            refreshCurrentStreak()
        }
    }
    
    private var chartSection: some View {
        Section("Drinks") {
            ChartView(
                drinkRecords: thisWeeksDrinks,
                totalStandardDrinksToday: totalStandardDrinksToday,
                totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
            )
        }
    }
    
    private var targetsSection: some View {
        Section("Limits") {
            if dailyTarget != nil {
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
                        let drinksOverTarget = remainingDrinksToday * -1
                        let noun = drinksOverTarget == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(drinksOverTarget)) \(noun) over limit")
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
                    
                    let remainingDrinks = weeklyTarget - totalStandardDrinksThisWeek
                    if remainingDrinks > 0 {
                        let noun = remainingDrinks == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(remainingDrinks)) \(noun) below limit")
                    } else if remainingDrinks == weeklyTarget {
                        Text("Weekly limit reached!")
                    } else {
                        let drinksOverTarget = remainingDrinks * -1
                        let noun = drinksOverTarget == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(drinksOverTarget)) \(noun) over limit")
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

    MainScreen()
        .modelContainer(container)
}
