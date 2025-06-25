//
//  CustomDrink.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation
import SwiftData

// MARK: - Current Model Typealias
typealias CustomDrink = AppSchemaV2.CustomDrink

extension AppSchemaV2 {
    @Model
    final class CustomDrink {
        var name: String = ""
        var standardDrinks: Double = 0.0
        
        init(name: String, standardDrinks: Double) {
            self.name = name
            self.standardDrinks = standardDrinks
        }
    }
}

extension AppSchemaV1 {
    @Model
    final class CustomDrink {
        var name: String = ""
        var standardDrinks: Double = 0.0
        
        init(name: String, standardDrinks: Double) {
            self.name = name
            self.standardDrinks = standardDrinks
        }
    }
}
