//
//  DrinkTrackerModel.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import Foundation
import Observation
import SwiftData

@Observable
final class DrinkTrackerModel {
    var dayLogs = [DayLog]()
    
    var startOfWeek: Date {
        return Calendar.current.dateComponents(
            [
                .calendar,
                .yearForWeekOfYear,
                .weekOfYear
            ],
            from: Date()
        ).date!
    }
    
    var endOfWeek: Date {
        return Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: startOfWeek
        )!
    }
    
    var todaysLog: DayLog {
        if let dayLog = dayLogs.first(where: {
            Calendar.current.isDateInToday($0.date)
        }) {
            return dayLog
        } else {
            let dayLog = DayLog()
            context.insert(dayLog)
            return dayLog
        }
    }
    
    var totalStandardDrinksToday: Double { todaysLog.totalDrinks }
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func refresh() {
        fetchDayLogs()
    }
    
    func fetchDayLogs() {
        let dayLogs = FetchDescriptor(
            predicate: #Predicate<DayLog> { $0.date >= startOfWeek && $0.date < endOfWeek },
            sortBy: [SortDescriptor(\DayLog.date)]
        )
        
        do {
            self.dayLogs = try context.fetch(dayLogs)
        } catch {
            self.dayLogs = []
        }
    }
    
    func addCatalogDrink(_ catalogDrink: CustomDrink) {
        context.insert(catalogDrink)
    }
    
    func recordDrink(_ drink: DrinkRecord) {
        todaysLog.addDrink(drink)
    }
}
