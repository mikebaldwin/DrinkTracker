//
//  IngredientTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 5/24/24.
//

@testable import DrinkTracker
import XCTest

final class IngredientTests: XCTestCase {
    
    func testIsEmptyWithEmptyStrings() {
        let ingredient = Ingredient(volume: "", abv: "")
        XCTAssertTrue(ingredient.isEmpty)
    }
    
    func testIsEmptyWithZeros() {
        let ingredient = Ingredient(volume: "0", abv: "0")
        XCTAssertTrue(ingredient.isEmpty)
    }
    
    func testIsEmptyWithNegativeNumbers() {
        let ingredient = Ingredient(volume: "-1", abv: "-20")
        XCTAssertTrue(ingredient.isEmpty)
    }
    
    func testIsValidSuccess() {
        let ingredient = Ingredient(volume: "2", abv: "40")
        XCTAssertTrue(ingredient.isValid)
    }
    
    func testIsValidEmptyVolumeFailure() {
        let ingredient = Ingredient(volume: "", abv: "40")
        XCTAssertFalse(ingredient.isValid)
    }
    
    func testIsValidZeroVolumeFailure() {
        let ingredient = Ingredient(volume: "0", abv: "40")
        XCTAssertFalse(ingredient.isValid)
    }
    
    func testIsValidEmptyABVFailure() {
        let ingredient = Ingredient(volume: "2", abv: "")
        XCTAssertFalse(ingredient.isValid)
    }
    
    func testIsValidZeroABVFailure() {
        let ingredient = Ingredient(volume: "2", abv: "0")
        XCTAssertFalse(ingredient.isValid)
    }
    
    func testIsValidAllEmptyFailure() {
        let ingredient = Ingredient(volume: "", abv: "")
        XCTAssertFalse(ingredient.isValid)
    }
    
    func testIsValidAllZerosFailure() {
        let ingredient = Ingredient(volume: "0", abv: "0")
        XCTAssertFalse(ingredient.isValid)
    }
}
