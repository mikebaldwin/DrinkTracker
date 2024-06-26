//
//  DrinkCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/6/24.
//

import Foundation

struct DrinkCalculator {
    func calculateStandardDrinks(_ ingredients: [Ingredient]) -> Double {
        ingredients
            .filter { $0.isValid }
            .reduce(into: 0.0) { result, ingredient in
                var volume = Double(ingredient.volume)!
                if ingredient.isMetric {
                    // convert to oz
                    volume *= .metricToImperial
                }
                
                var strength = Double(ingredient.strength)!
                if ingredient.isProof {
                    strength /= 2
                }
                
                let standardDrinks = (volume * strength * 0.01) / 0.6
                return result += (standardDrinks * 100).rounded() / 100
            }
    }
    
    func volumeForOneStandardDrink(_ ingredient: Ingredient) -> Double {
        var strength = Double(ingredient.strength)!
        if ingredient.isProof {
            strength /= 2
        }
        
        if ingredient.isMetric {
            let standardDrinkGrams = 14.0
            let ethanolDensity = 0.789
            return (standardDrinkGrams / (strength * ethanolDensity)) * 100
        } else {
            let standardDrinkOunces = 0.6
            return (standardDrinkOunces / strength) * 100
        }
    }
}

private extension Double {
    static let metricToImperial = 0.033814
    static let imperialToMetric = 29.57353
}
