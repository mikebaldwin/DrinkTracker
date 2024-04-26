//
//  DrinkTrackerApp.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI
import SwiftData

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
        }
        .modelContainer(sharedModelContainer)
    }
}
