//
//  Item.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

@Model
final class Drink {
    let name: String?
    let standardDrinks: Double
    var timestamp: Date
    
    init(standardDrinks: Double, name: String?) {
        self.standardDrinks = standardDrinks
        self.name = name
        self.timestamp = Date()
    }
    
    init(_ catalogDrink: CatalogDrink) {
        self.name = catalogDrink.name
        self.standardDrinks = catalogDrink.standardDrinks
        self.timestamp = Date()
    }
}
