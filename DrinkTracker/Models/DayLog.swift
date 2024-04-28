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
    let date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \DrinkRecord.dayLog?)
    private(set) var drinks: [DrinkRecord]? = [DrinkRecord]()
    
    @Attribute(.ephemeral)
    var totalDrinks: Double {
        drinks!.reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
    
    init() { }
    
    func addDrink(_ drink: DrinkRecord) {
        drinks!.append(drink)
    }
}
