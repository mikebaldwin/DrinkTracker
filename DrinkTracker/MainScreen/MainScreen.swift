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
        filter: DrinkRecord.thisWeeksDrinksPredicate(),
        sort: [SortDescriptor(\DrinkRecord.timestamp)]
    ) private var drinkRecords: [DrinkRecord]
    
    @State private var showQuickEntryView = false
    @State private var showCalculatorView = false
    @State private var showCustomDrinksView = false
    @State private var showSettingsScreen = false
    
    private var healthStoreManager = HealthStoreManager.shared
    
    private var totalStandardDrinksToday: Double {
        drinkRecords
            .filter { Calendar.current.isDateInToday($0.timestamp) }
            .reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    private var totalStandardDrinksThisWeek: Double {
        drinkRecords.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Drinks") {
                    ChartView(
                        drinkRecords: drinkRecords,
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
                    }
                }
                Section {
                    Button {
                        showQuickEntryView = true
                    } label: {
                        Text("Quick Entry")
                    }
                    Button {
                        showCalculatorView = true
                    } label: {
                        Text("Drink Calculator")
                    }
                    Button {
                        showCustomDrinksView = true
                    } label: {
                        Text("Custom Drinks")
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
            QuickEntryView()
                .presentationDetents([.height(150)])
        }
        .sheet(isPresented: $showCalculatorView) {
            CalculatorView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showCustomDrinksView) {
            RecordCustomDrinkScreen(modelContext: modelContext) {
                recordDrink(DrinkRecord($0))
            }
        }
        .sheet(isPresented: $showSettingsScreen) {
            SettingsScreen()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                _ = drinkRecords
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

}

//#Preview {
//    MainScreen()
//        .modelContainer(previewContainer)
//}
