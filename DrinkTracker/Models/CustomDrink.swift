//
//  CatalogDrink.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

@Model
final class CustomDrink {
    let name: String = ""
    let standardDrinks: Double = 0.0
    
    init(name: String, standardDrinks: Double) {
        self.name = name
        self.standardDrinks = standardDrinks
    }
}
