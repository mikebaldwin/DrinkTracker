//
//  ModelContainer.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/6/24.
//

import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let schema = Schema([DayLog.self])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        )
        SampleData.dayLogs.enumerated().forEach { index, dayLog in
            container.mainContext.insert(dayLog)
        }
        
        return container
        
    } catch {
        fatalError("Failed to create container.")
    }
}()

struct SampleData {
    static let dayLogs: [DayLog] = {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        var days: [DayLog] = []

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let dayLog = DayLog(date: date)
                days.append(dayLog)
            }
        }
        for day in days {
//            _ = (0...Int.random(in: 1...3)).map { _ in
                day.addDrink(
                    DrinkRecord(
                        standardDrinks: Double(Int.random(in: 1...2)),
                        name: "Randomly generated drink"
                    )
                )
//            }
        }
        
        return days
    }()
}
