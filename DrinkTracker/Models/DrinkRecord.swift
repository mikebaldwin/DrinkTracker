//
//  Item.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

@Model
final class DrinkRecord: Identifiable {
    var dayLog: DayLog?
    let id = UUID().uuidString
    let name: String?
    let standardDrinks: Double = 0.0
    var timestamp = Date()
    
    init(standardDrinks: Double, name: String?) {
        self.standardDrinks = standardDrinks
        self.name = name
    }
    
    init(_ catalogDrink: CustomDrink) {
        self.name = catalogDrink.name
        self.standardDrinks = catalogDrink.standardDrinks
    }
}
