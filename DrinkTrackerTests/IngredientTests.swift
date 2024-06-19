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
    func ingredientIsEmptyWithInvalidData(_ ingredient: Ingredient) {
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
    func ingredientValidationFailure(_ ingredient: Ingredient) {
        #expect(!ingredient.isValid)
    }
    
    @Test(
        "Test ingredient has ABV and no volume",
        arguments: [
            Ingredient(volume: "", abv: "40"),
            Ingredient(volume: "0", abv: "40")
        ]
    )
    func ingredientHasOnlyABV(_ ingredient: Ingredient) {
        #expect(ingredient.hasOnlyABV)
    }
    
    @Test("Test ingredient hasOnlyABV failure")
    func ingredientHasABV() {
        let ingredient = Ingredient(volume: "2", abv: "40")
        #expect(!ingredient.hasOnlyABV)
    }
}
