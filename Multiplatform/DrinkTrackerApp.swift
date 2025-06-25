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
    
    private let quickActionHandler = QuickActionHandler.shared
    private let appRouter = AppRouter()
    
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
            Group {
                if let settingsStore {
                    MainScreen()
                        .environment(quickActionHandler)
                        .environment(appRouter)
                        .environment(settingsStore)
                } else {
                    // Loading state while SettingsStore initializes
                    Text("Loading...")
                        .onAppear {
                            initializeSettingsStore()
                        }
                }
            }
            .onChange(of: quickActionHandler.activeAction) { action, _ in
                if action != nil {
                    // The action will be handled by MainScreen's environment observation
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
                    // authorized - sync will happen in MainScreen
                    break
                case .failure(let error):
                    Logger.ui.error("An error occurred while requesting authentication: \(error.localizedDescription)")
                }
            }
            .task {
                // Clear any existing dynamic quick actions to prevent duplicates
                Task { @MainActor in
                    UIApplication.shared.shortcutItems = nil
                    Logger.ui.info("Cleared any existing dynamic Quick Actions")
                }
                
                // HealthKit availability check - no action needed
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func initializeSettingsStore() {
        let context = sharedModelContainer.mainContext
        settingsStore = SettingsStore(modelContext: context)
    }
}
