//
//  DrinkRecord.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

// MARK: - Current Model Typealias
typealias DrinkRecord = AppSchemaV3.DrinkRecord

extension AppSchemaV3 {
    @Model
    final class DrinkRecord: Identifiable {
        var id = UUID().uuidString
        var standardDrinks: Double = 0.0
        var timestamp = Date()
        
        init(standardDrinks: Double, date: Date = Date()) {
            self.standardDrinks = standardDrinks
            self.timestamp = date
        }
        
        init(_ customDrink: CustomDrink) {
            self.standardDrinks = customDrink.standardDrinks
        }
        
        static func thisWeeksDrinksPredicate() -> Predicate<DrinkRecord> {
            let startOfCurrentWeek = Date.startOfWeek
            
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp >= startOfCurrentWeek
            }
        }
        
        static func todaysDrinksPredicate() -> Predicate<DrinkRecord> {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            let tomorrow = Date.tomorrow
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp < tomorrow && drinkRecord.timestamp >= startOfToday
            }
        }
    }
}

extension AppSchemaV2 {
    @Model
    final class DrinkRecord: Identifiable {
        var id = UUID().uuidString
        var standardDrinks: Double = 0.0
        var timestamp = Date()
        
        init(standardDrinks: Double, date: Date = Date()) {
            self.standardDrinks = standardDrinks
            self.timestamp = date
        }
        
        init(_ customDrink: CustomDrink) {
            self.standardDrinks = customDrink.standardDrinks
        }
        
        static func thisWeeksDrinksPredicate() -> Predicate<DrinkRecord> {
            let startOfCurrentWeek = Date.startOfWeek
            
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp >= startOfCurrentWeek
            }
        }
        
        static func todaysDrinksPredicate() -> Predicate<DrinkRecord> {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            let tomorrow = Date.tomorrow
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp < tomorrow && drinkRecord.timestamp >= startOfToday
            }
        }
    }
}

extension AppSchemaV1 {
    @Model
    final class DrinkRecord: Identifiable {
        var id = UUID().uuidString
        var standardDrinks: Double = 0.0
        var timestamp = Date()
        
        init(standardDrinks: Double, date: Date = Date()) {
            self.standardDrinks = standardDrinks
            self.timestamp = date
        }
        
        init(_ customDrink: CustomDrink) {
            self.standardDrinks = customDrink.standardDrinks
        }
        
        static func thisWeeksDrinksPredicate() -> Predicate<DrinkRecord> {
            let startOfCurrentWeek = Date.startOfWeek
            
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp >= startOfCurrentWeek
            }
        }
        
        static func todaysDrinksPredicate() -> Predicate<DrinkRecord> {
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            let tomorrow = Date.tomorrow
            return #Predicate<DrinkRecord> { drinkRecord in
                drinkRecord.timestamp < tomorrow && drinkRecord.timestamp >= startOfToday
            }
        }
    }
}
