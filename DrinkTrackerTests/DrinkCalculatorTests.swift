//
//  DrinkCalculatorTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 5/6/24.
//

@testable import DrinkTracker
import XCTest

final class DrinkCalculatorTests: XCTestCase {
    private var calculator: DrinkCalculator!

    override func setUp() {
        calculator = DrinkCalculator()
    }
    
    func testGenericDrinkCalculation() {
        let genericDrink = calculator.calculateStandardDrinks([Ingredient(volume: "1.5", abv: "40")])
        XCTAssertEqual(genericDrink, 1)
    }
    
    func testMartiniCalculation() {
        let martini = calculator.calculateStandardDrinks(
            [
                Ingredient(volume: "2.0", abv: "40"),
                Ingredient(volume: "1.0", abv: "18")
            ]
        )
        XCTAssertEqual(martini, 1.6, accuracy: .accuracy)
    }
    
    func testDaiquiri() {
        let daiquiri = calculator.calculateStandardDrinks([Ingredient(volume: "2", abv: "41.2")])
        XCTAssertEqual(daiquiri, 1.4, accuracy: .accuracy)
    }
    
    func testJetPilot() {
        let jetPilot = calculator.calculateStandardDrinks(
            [
                Ingredient(volume: "1", abv: "40"),
                Ingredient(volume: "0.75", abv: "40"),
                Ingredient(volume: "0.75", abv: "69"),
                Ingredient(volume: "0.5", abv: "18"),
                Ingredient(volume: "0.02", abv: "50")
            ]
            
        )
        XCTAssertEqual(jetPilot, 2.2, accuracy: .accuracy)
    }
    
    func testOuncesForFortyPercentAlcohol() {
        let abv = 40.0
        let ounces = calculator.ouncesForOneStandardDrink(abv: abv)
        XCTAssertEqual(ounces, 1.5)
    }
    
    func testOuncesForNinePercentAlcohol() {
        let abv = 9.0
        let ounces = calculator.ouncesForOneStandardDrink(abv: abv)
        XCTAssertEqual(ounces, 6.7, accuracy: .accuracy)
    }
    
    func testOuncesForFourteenPercentAlcohol() {
        let ounces = calculator.ouncesForOneStandardDrink(abv: 14.0)
        XCTAssertEqual(ounces, 4.3, accuracy: .accuracy)
    }
}

private extension Double {
    static var accuracy = 0.1
}
