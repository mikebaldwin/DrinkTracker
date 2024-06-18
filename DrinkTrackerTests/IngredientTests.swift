//
//  IngredientTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 5/24/24.
//

@testable import DrinkTracker
import Testing

@Suite("Ingredient Tests")
struct IngredientTests {
    
    @Test(
        "Test ingredient isEmpty success",
        arguments: [
            Ingredient(volume: "", abv: ""),
            Ingredient(volume: "0", abv: "0"),
            Ingredient(volume: "-1", abv: "-20")
        ]
    )
    func isEmptyWithEmptyStrings(_ ingredient: Ingredient) {
        #expect(ingredient.isEmpty)
    }
    
    @Test("Test ingredient validation success")
    func isValidSuccess() {
        let ingredient = Ingredient(volume: "2", abv: "40")
        #expect(ingredient.isValid)
        #expect(!ingredient.isEmpty)
    }
    
    @Test(
        "Test ingredient validation failures",
        arguments: [
            Ingredient(volume: "", abv: "40"),
            Ingredient(volume: "0", abv: "40"),
            Ingredient(volume: "2", abv: ""),
            Ingredient(volume: "2", abv: "0"),
            Ingredient(volume: "", abv: ""),
            Ingredient(volume: "0", abv: "0")
        ]
    )
    func isInvalidWithEmptyVolume(_ ingredient: Ingredient) {
        #expect(!ingredient.isValid)
    }
}
