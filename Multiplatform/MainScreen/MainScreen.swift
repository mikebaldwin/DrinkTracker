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
    @AppStorage("dailyTarget") private var dailyLimit: Double?
    @AppStorage("weeklyTarget") private var weeklyLimit: Double?
    @AppStorage("longestStreak") private var longestStreak = 0
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppRouter.self) private var router
    @Environment(QuickActionHandler.self) private var quickActionHandler
    
    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) private var allDrinks: [DrinkRecord]
    
    @State private var currentStreak = 0
    @State private var recordingDrinkComplete = false
    
    private var healthStoreManager = HealthStoreManager.shared
    
    private var thisWeeksDrinks: [DrinkRecord] {
        allDrinks.thisWeeksRecords
    }
    private var todaysDrinks: [DrinkRecord] {
        allDrinks.todaysRecords
    }
    private var totalStandardDrinksToday: Double {
        allDrinks.todaysRecords.totalStandardDrinks
    }
    private var totalStandardDrinksThisWeek: Double {
        allDrinks.thisWeeksRecords.totalStandardDrinks
    }
    private var remainingDrinksToday: Double {
        DrinkLimitCalculator.remainingDrinksToday(
            dailyLimit: dailyLimit,
            weeklyLimit: weeklyLimit,
            totalToday: totalStandardDrinksToday,
            totalThisWeek: totalStandardDrinksThisWeek
        )
    }
    
    var body: some View {
        NavigationStack(path: Bindable(router).navigationPath) {
            Form {
                ChartView(
                    drinkRecords: thisWeeksDrinks,
                    totalStandardDrinksToday: totalStandardDrinksToday,
                    totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
                )
                
                
                if dailyLimit != nil || weeklyLimit != nil {
                    LimitsSection(
                        dailyLimit: dailyLimit,
                        weeklyLimit: weeklyLimit,
                        remainingDrinksToday: remainingDrinksToday,
                        totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
                    )
                }
                
                StreaksSection(
                    currentStreak: currentStreak,
                    longestStreak: longestStreak
                )
                
                ActionsSection(
                    onCalculatorTap: {
                        router.presentCalculator(
                            createCustomDrink: addCustomDrink,
                            createDrinkRecord: recordDrink
                        )
                    },
                    onCustomDrinkTap: {
                        router.presentCustomDrink { customDrink in
                            recordDrink(DrinkRecord(customDrink))
                        }
                    },
                    onQuickEntryTap: {
                        router.presentSheet(.quickEntry)
                    }
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        router.presentSettings()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                viewFor(destination: destination)
            }
        }
        .sensoryFeedback(.success, trigger: recordingDrinkComplete)
        .sheet(item: Bindable(router).presentedSheet) { sheet in
            viewFor(sheet: sheet)
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
        .onChange(of: quickActionHandler.activeAction) { _, activeAction in
            if let activeAction {
                router.handleQuickAction(activeAction)
                quickActionHandler.clearAction()
            }
        }
        .onAppear {
            router.setQuickActionHandlers(
                addCustomDrink: addCustomDrink,
                recordDrink: recordDrink
            )
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
        recordingDrinkComplete.toggle()
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
    
    // MARK: - Navigation Helpers

    private func viewFor(destination: Destination) -> some View {
        switch destination {
        case .drinksHistory:
            return AnyView(DrinksHistoryScreen().environment(router))
        case .drinkDetail(let drinkRecord):
            return AnyView(DrinkRecordDetailScreen(drinkRecord: drinkRecord, completion: router.didFinishUpdatingDrinkRecord))
        default:
            return AnyView(EmptyView())
        }
    }

    private func viewFor(sheet: SheetDestination) -> some View {
        switch sheet {
        case .quickEntry:
            return AnyView(QuickEntryView { drinkRecord in
                recordDrink(drinkRecord)
                router.dismiss()
            }
            .presentationDetents([.fraction(0.2)]))
        case .calculator(let createCustomDrink, let createDrinkRecord):
            return AnyView(CalculatorScreen(
                createCustomDrink: createCustomDrink,
                createDrinkRecord: createDrinkRecord
            )
            .presentationDetents([.large]))
        case .customDrink(let completion):
            return AnyView(CustomDrinkScreen(completion: completion))
        case .settings:
            return AnyView(SettingsScreen())
        }
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(
//        for: DrinkRecord.self,
//        configurations: config
//    )
//
//    MainScreen()
//        .modelContainer(container)
//}
