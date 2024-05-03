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
    var customDrinks = [CustomDrink]()
    var totalStandardDrinksToday: Double { todaysLog.totalDrinks }
    var totalStandardDrinksThisWeek: Double {
        dayLogs.reduce(into: 0.0) { partialResult, dayLog in
            partialResult += dayLog.totalDrinks
        }
    }

    private var todaysLog: DayLog {
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
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        fetchDayLogs()
        _ = todaysLog
    }
    
    func fetchDayLogs() {
        let dayLogs = FetchDescriptor(
            predicate: #Predicate<DayLog> { $0.date >= DateMath.startOfWeek && $0.date < DateMath.endOfWeek },
            sortBy: [SortDescriptor(\DayLog.date)]
        )
        
        do {
            self.dayLogs = try context.fetch(dayLogs)
        } catch {
            self.dayLogs = []
        }
    }
    
    func fetchCustomDrinks() {
        let customDrinks = FetchDescriptor<CustomDrink>(sortBy: [SortDescriptor(\.name)])
        do {
            self.customDrinks = try context.fetch(customDrinks)
        } catch {
            self.customDrinks = []
        }
    }
    
    func addCatalogDrink(_ catalogDrink: CustomDrink) {
        context.insert(catalogDrink)
    }
    
    func recordDrink(_ drink: DrinkRecord) {
        todaysLog.addDrink(drink)
    }
}
