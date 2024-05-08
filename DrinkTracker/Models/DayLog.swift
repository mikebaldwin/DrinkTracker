//
//  DayRecord.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/26/24.
//

import Foundation
import SwiftData

@Model
final class DayLog {
    private(set) var date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \DrinkRecord.dayLog?)
    private(set) var drinks: [DrinkRecord]? = [DrinkRecord]()
    
    @Attribute(.ephemeral)
    var totalDrinks: Double {
        drinks!.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    
    init(date: Date? = Date()) { }
    
    func addDrink(_ drink: DrinkRecord) {
        drinks!.append(drink)
    }
    
    func addDrinks(_ drinks: [DrinkRecord]) {
        drinks.forEach { self.drinks!.append($0) }
    }
    
    func removeDrink(_ drink: DrinkRecord) {
        if let index = drinks!.firstIndex(of: drink) {
            drinks!.remove(at: index)
        }
    }
}
