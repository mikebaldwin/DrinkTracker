//
//  Item.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

@Model
final class DrinkRecord: Identifiable, Sendable {
    var dayLog: DayLog?
    let id = UUID().uuidString
    var standardDrinks: Double = 0.0
    var timestamp = Date()
    
    init(standardDrinks: Double, date: Date = Date()) {
        self.standardDrinks = standardDrinks
        self.timestamp = date
    }
    
    init(_ catalogDrink: CustomDrink) {
        self.standardDrinks = catalogDrink.standardDrinks
    }
    
    static func thisWeeksDrinksPredicate() -> Predicate<DrinkRecord> {
        let startOfCurrentWeek = Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: Date()
            )
        )!
        
        return #Predicate<DrinkRecord> { drinkRecord in
            drinkRecord.timestamp >= startOfCurrentWeek
        }
    }
}
