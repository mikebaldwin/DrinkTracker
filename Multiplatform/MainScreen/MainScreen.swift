//
//  MainScreen.swift
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
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(QuickActionHandler.self) private var quickActionHandler
    
    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) private var allDrinks: [DrinkRecord]
    
    private var businessLogic: MainScreenBusinessLogic {
        MainScreenBusinessLogic.create(context: modelContext)
    }
    
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
                    currentStreak: businessLogic.currentStreak,
                    longestStreak: businessLogic.longestStreak
                )
                
                ActionsSection(
                    onCalculatorTap: {
                        router.presentCalculator(
                            createCustomDrink: businessLogic.addCustomDrink,
                            createDrinkRecord: { drink in
                                Task { await businessLogic.recordDrink(drink) }
                            }
                        )
                    },
                    onCustomDrinkTap: {
                        router.presentCustomDrink { customDrink in
                            Task { await businessLogic.recordDrink(DrinkRecord(customDrink)) }
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
        .sensoryFeedback(.success, trigger: businessLogic.recordingDrinkComplete)
        .sheet(item: Bindable(router).presentedSheet) { sheet in
            viewFor(sheet: sheet)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                _ = allDrinks
                businessLogic.refreshCurrentStreak(from: allDrinks)
            }
        }
        .onChange(of: allDrinks) {
            businessLogic.refreshCurrentStreak(from: allDrinks)
        }
        .onChange(of: quickActionHandler.activeAction) { _, activeAction in
            if let activeAction {
                router.handleQuickAction(activeAction)
                quickActionHandler.clearAction()
            }
        }
        .onAppear {
            router.setQuickActionHandlers(
                addCustomDrink: businessLogic.addCustomDrink,
                recordDrink: { drink in
                    Task { await businessLogic.recordDrink(drink) }
                }
            )
            
            // Initial sync on app launch
            if HKHealthStore.isHealthDataAvailable() {
                Task {
                    await businessLogic.syncData()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .syncConflictsDetected)) { notification in
            if let conflicts = notification.object as? [SyncConflict] {
                router.presentConflictResolution(conflicts: conflicts) { wasSuccessful in
                    // Conflict resolution completion is handled automatically
                    // No need to re-sync as successful resolution eliminates conflicts
                    // and failed resolution will be retried on next app launch
                }
            }
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
                Task { await businessLogic.recordDrink(drinkRecord) }
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
        case .conflictResolution(let conflicts, let onComplete):
            return AnyView(ConflictResolutionScreen(
                conflicts: conflicts,
                onResolutionComplete: onComplete
            ))
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
