//
//  DrinkTrackerApp.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI
import SwiftData
import HealthKitUI

@main
struct DrinkTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DrinkRecord.self,
            CustomDrink.self
        ])
        let modelConfiguration = ModelConfiguration(
            nil,
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.mikebaldwin.DrinkTracker")
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
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
                        // authorized
                        if retrySync == true {
                            Task {
                                await syncData()
                                retrySync = false
                            }
                        }
                    case .failure(let error):
                        debugPrint("*** An error occurred while requesting authentication: \(error) ***")
                    }
                }
                .task {
                    if HKHealthStore.isHealthDataAvailable() {
                        await syncData()
                    } else {
                        retrySync = true
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    @State private var trigger = false
    @State private var retrySync = false
    
    private func syncData() async {
        await DataSynchronizer(container: sharedModelContainer)
            .updateDrinkRecords()
    }
}
