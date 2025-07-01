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
    @Environment(SettingsStore.self) private var settingsStore
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(QuickActionHandler.self) private var quickActionHandler
    
    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) private var allDrinks: [DrinkRecord]
    
    @State private var currentStreak: Int = 0
    @State private var factRandomizationTrigger: Int = 0
    
    private var dailyLimit: Double? {
        settingsStore.dailyLimit > 0 ? settingsStore.dailyLimit : nil
    }
    
    private var weeklyLimit: Double? {
        settingsStore.weeklyLimit > 0 ? settingsStore.weeklyLimit : nil
    }
    
    private var longestStreak: Int {
        settingsStore.longestStreak
    }
    
    private var healingMomentumDays: Double {
        settingsStore.healingMomentumDays
    }
    
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
    
    private var drinkingStatus7Days: DrinkingStatus? {
        DrinkingStatusCalculator.calculateStatus(
            for: .week7,
            drinks: allDrinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
    }
    
    private var drinkingStatus30Days: DrinkingStatus? {
        DrinkingStatusCalculator.calculateStatus(
            for: .days30,
            drinks: allDrinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
    }
    
    private var drinkingStatusYear: DrinkingStatus? {
        DrinkingStatusCalculator.calculateStatus(
            for: .year,
            drinks: allDrinks,
            userSex: settingsStore.userSex,
            trackingStartDate: settingsStore.drinkingStatusStartDate
        )
    }
    
    private var weeklyProgressMessage: String {
        DrinkLimitCalculator.weeklyProgressMessage(
            weeklyLimit: weeklyLimit,
            totalThisWeek: totalStandardDrinksThisWeek
        )
    }
    
    private var onCalculatorTap: () -> Void {
        {
            router.presentCalculator(
                createCustomDrink: businessLogic.addCustomDrink,
                createDrinkRecord: { drink in
                    Task { await businessLogic.recordDrink(drink) }
                }
            )
        }
    }
    
    private var onCustomDrinkTap: () -> Void {
        {
            router.presentCustomDrink { customDrink in
                Task { await businessLogic.recordDrink(DrinkRecord(customDrink)) }
            }
        }
    }
    
    private var onQuickEntryTap: () -> Void {
        {
            router.presentSheet(.quickEntry)
        }
    }
    
    @ViewBuilder
    private func mainContentView() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                DashboardCardView(
                    currentStreak: currentStreak,
                    drinkingStatus7Days: drinkingStatus7Days,
                    drinkingStatus30Days: drinkingStatus30Days,
                    drinkingStatusYear: drinkingStatusYear,
                    weeklyProgress: weeklyProgressMessage,
                    drinkRecords: allDrinks,
                    settingsStore: settingsStore
                )
                
                HistoryNavigationCard {
                    router.push(.drinksHistory)
                }
                
                AlcoholFreeDaysCard(
                    currentStreak: currentStreak,
                    longestStreak: longestStreak,
                    showSavings: settingsStore.showSavings,
                    monthlyAlcoholSpend: settingsStore.monthlyAlcoholSpend,
                    healingMomentumDays: healingMomentumDays,
                    randomizationTrigger: factRandomizationTrigger
                )
                
                if dailyLimit != nil || weeklyLimit != nil {
                    LimitsCard(
                        dailyLimit: dailyLimit,
                        weeklyLimit: weeklyLimit,
                        remainingDrinksToday: remainingDrinksToday,
                        totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
                    )
                }
                
                ActionsSection(
                    onCalculatorTap: onCalculatorTap,
                    onCustomDrinkTap: onCustomDrinkTap,
                    onQuickEntryTap: onQuickEntryTap
                )
            }
            .padding(.horizontal, 16)
        }
    }
    
    
    var body: some View {
        NavigationStack(path: Bindable(router).navigationPath) {
            mainContentView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            router.presentSettings()
                        } label: {
                            Image(systemName: "gearshape")
                                .accessibilityHidden(true)
                        }
                        .accessibilityLabel("Settings")
                        .accessibilityHint("Opens app settings and preferences")
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
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: allDrinks) {
            handleDrinksChange()
        }
        .onChange(of: quickActionHandler.activeAction) { _, activeAction in
            handleQuickActionChange(activeAction)
        }
        .onAppear {
            handleOnAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: .syncConflictsDetected)) { notification in
            handleSyncConflicts(notification)
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .active {
            _ = allDrinks
            currentStreak = businessLogic.refreshCurrentStreak(from: allDrinks, settingsStore: settingsStore)
            settingsStore.updateHealingMomentum(with: allDrinks)  // Always update on foreground
            factRandomizationTrigger += 1  // Trigger brain fact randomization
        }
    }
    
    private func handleDrinksChange() {
        currentStreak = businessLogic.refreshCurrentStreak(from: allDrinks, settingsStore: settingsStore)
        settingsStore.updateHealingMomentum(with: allDrinks)  // Always update
    }
    
    private func handleQuickActionChange(_ activeAction: QuickActionType?) {
        if let activeAction {
            router.handleQuickAction(activeAction)
            quickActionHandler.clearAction()
        }
    }
    
    private func handleOnAppear() {
        currentStreak = businessLogic.refreshCurrentStreak(from: allDrinks, settingsStore: settingsStore)
        
        // Always initialize and update healing momentum
        settingsStore.initializeHealingMomentumIfNeeded(with: allDrinks)
        settingsStore.updateHealingMomentum(with: allDrinks)
        
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
    
    private func handleSyncConflicts(_ notification: Notification) {
        if let conflicts = notification.object as? [SyncConflict] {
            router.presentConflictResolution(conflicts: conflicts) { wasSuccessful in
                // Conflict resolution completion is handled automatically
                // No need to re-sync as successful resolution eliminates conflicts
                // and failed resolution will be retried on next app launch
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
