//
//  DrinkCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/6/24.
//

import Foundation

struct DrinkCalculator {
    func calculateStandardDrinks(_ ingredients: [Ingredient]) -> Double {
        ingredients.reduce(into: 0.0) { result, ingredient in
            let volume = Double(ingredient.volume)!
            let abv = Double(ingredient.abv)!
            let standardDrinks = (volume * abv * 0.01) / 0.6
            return result += (standardDrinks * 100).rounded() / 100
        }
    }
    
    func ouncesForOneStandardDrink(abv: Double) -> Double {
        let standardDrinkOunces = 0.6
        return (standardDrinkOunces / abv) * 100
    }
}
