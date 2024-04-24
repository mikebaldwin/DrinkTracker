//
//  CatalogDrink.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

@Model
final class CatalogDrink {
    let name: String
    let standardDrinks: Double
    
    init(name: String, standardDrinks: Double) {
        self.name = name
        self.standardDrinks = standardDrinks
    }
}
