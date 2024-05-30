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
    @State private var trigger = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DayLog.self,
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
                    shareTypes: allTypes,
                    readTypes: allTypes,
                    trigger: trigger
                ) { result in
                    switch result {
                    case .success(_):
                        // authorized
                        break
                    case .failure(let error):
                        // Handle the error here.
                        fatalError("*** An error occurred while requesting authentication: \(error) ***")
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private let allTypes: Set = [HKQuantityType(.numberOfAlcoholicBeverages)]
}
