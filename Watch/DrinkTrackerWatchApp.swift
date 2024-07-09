//
//  DrinkTrackerWatchApp.swift
//  DrinkTrackerWatch Watch App
//
//  Created by Mike Baldwin on 6/21/24.
//

import HealthKitUI
import SwiftData
import SwiftUI

@main
struct DrinkTrackerWatchApp: App {
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
            ContentView()
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
//                        if retrySync == true {
//                            Task {
//                                await syncData()
//                                retrySync = false
//                            }
//                        }
                        break
                    case .failure(let error):
                        debugPrint("*** An error occurred while requesting authentication: \(error) ***")
                    }
                }
//                .task {
//                    if HKHealthStore.isHealthDataAvailable() {
//                        await syncData()
//                    } else {
//                        retrySync = true
//                    }
//                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    @State private var trigger = false
//    @State private var retrySync = false
    
//    private func syncData() async {
//        await DataSynchronizer(container: sharedModelContainer)
//            .updateDrinkRecords()
//    }

}
