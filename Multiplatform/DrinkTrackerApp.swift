//
//  DrinkTrackerApp.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI
import SwiftData
import HealthKitUI
import UIKit
import OSLog

@main
struct DrinkTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var trigger = false
    @State private var settingsStore: SettingsStore?
    @State private var mainScreenBusinessLogic: MainScreenBusinessLogic?

    private let quickActionHandler = QuickActionHandler.shared
    private let appRouter = AppRouter()
    
    private var isUITesting: Bool {
        UITestingHelpers.isUITesting
    }
    
    var sharedModelContainer: ModelContainer = {
        let modelConfiguration = ModelConfiguration(
            cloudKitDatabase: .private("iCloud.com.mikebaldwin.DrinkTracker")
        )
        
        do {
            return try ModelContainer(
                for: DrinkRecord.self, CustomDrink.self, UserSettings.self,
                migrationPlan: AppMigrationPlan.self,
                configurations: modelConfiguration
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            if isUITesting {
                // UI Testing mode - skip HealthKit entirely
                Group {
                    if let settingsStore, let mainScreenBusinessLogic {
                        MainScreen()
                            .environment(quickActionHandler)
                            .environment(appRouter)
                            .environment(settingsStore)
                            .environment(mainScreenBusinessLogic)
                    } else {
                        Text("Loading...")
                            .onAppear {
                                initializeSettingsStore()
                                initializeMainScreenBusinessLogic()
                            }
                    }
                }
                .onChange(of: quickActionHandler.activeAction) { action, _ in
                    if action != nil {
                        quickActionHandler.clearAction()
                    }
                }
                .onAppear() {
                    Logger.ui.debug("UI Testing mode - skipping HealthKit")
                }
            } else {
                // Normal mode - include HealthKit authorization
                Group {
                    if let settingsStore, let mainScreenBusinessLogic {
                        MainScreen()
                            .environment(quickActionHandler)
                            .environment(appRouter)
                            .environment(settingsStore)
                            .environment(mainScreenBusinessLogic)
                    } else {
                        Text("Loading...")
                            .onAppear {
                                initializeSettingsStore()
                                initializeMainScreenBusinessLogic()
                            }
                    }
                }
                .onChange(of: quickActionHandler.activeAction) { action, _ in
                    if action != nil {
                        quickActionHandler.clearAction()
                    }
                }
                .onAppear() {
                    if HKHealthStore.isHealthDataAvailable() {
                        trigger.toggle()
                    }
                }
                .healthDataAccessRequest(
                    store: HealthStoreManager.shared.healthStore,
                    shareTypes: [HKQuantityType(.numberOfAlcoholicBeverages)],
                    readTypes: [HKQuantityType(.numberOfAlcoholicBeverages)],
                    trigger: trigger
                ) { result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        Logger.ui.error("An error occurred while requesting authentication: \(error.localizedDescription)")
                    }
                }
                .task {
                    Task { @MainActor in
                        UIApplication.shared.shortcutItems = nil
                        Logger.ui.info("Cleared any existing dynamic Quick Actions")
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func initializeSettingsStore() {
        let context = sharedModelContainer.mainContext
        settingsStore = SettingsStore(modelContext: context)
    }

    private func initializeMainScreenBusinessLogic() {
        let context = sharedModelContainer.mainContext
        mainScreenBusinessLogic = MainScreenBusinessLogic.create(context: context)
    }
}
