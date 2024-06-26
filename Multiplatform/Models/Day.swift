//
//  Day.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/4/24.
//

import Foundation

struct Day: Identifiable {
    var id = UUID()
    var date: Date
    var drinks: [DrinkRecord]
    var totalDrinks: Double {
        drinks.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    
    init(date: Date, drinks: [DrinkRecord] = []) {
        self.date = date
        self.drinks = drinks
    }
    
    mutating func addDrink(_ drink: DrinkRecord) {
        drinks.append(drink)
    }
    
    mutating func addDrinks(_ drinks: [DrinkRecord]) {
        drinks.forEach { self.drinks.append($0) }
    }
    
    mutating func removeDrink(_ drink: DrinkRecord) {
        if let index = drinks.firstIndex(of: drink) {
            drinks.remove(at: index)
        }
    }
}
