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
        guard let dailyLimit else { return 0 }
        
        var remaining = dailyLimit - totalStandardDrinksToday
        
        if let weeklyLimit {
            let remainingForWeek = weeklyLimit - totalStandardDrinksThisWeek
            if remaining >= remainingForWeek {
                remaining = totalStandardDrinksToday == 0 ? 0 : remainingForWeek
            }
        }
        
        return remaining
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
                    limitsSection
                }
                
                streaksSection
                
                actionsSection
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
    
    private var limitsSection: some View {
        Section("Limits") {
            if dailyLimit != nil {
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
                    if remainingDrinks > 0 {
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
                Text("\(longestStreak) days")
            }
        }
    }
    
    private var actionsSection: some View {
        Section {
            Button {
                router.presentCalculator(
                    createCustomDrink: addCustomDrink,
                    createDrinkRecord: recordDrink
                )
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Drink Calculator")
                }
            }
            Button {
                router.presentCustomDrink { customDrink in
                    recordDrink(DrinkRecord(customDrink))
                }
            } label: {
                HStack {
                    Image(systemName: "wineglass")
                    Text("Custom Drinks")
                }
            }
            Button {
                router.presentSheet(.quickEntry)
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
