//
//  DrinkCalculatorTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 5/6/24.
//

@testable import DrinkTracker
import Testing

@Suite("DrinkCalculator tests") struct DrinkCalculatorTestss {
    private var calculator: DrinkCalculator
    
    init() {
        calculator = DrinkCalculator()
    }
    
    @Test(
        "Calculate one standard drink",
        arguments: [
            Ingredient(volume: "1.5", strength: "40"),
            Ingredient(volume: "5", strength: "12"),
            Ingredient(volume: "12", strength: "5")
        ]
    )
    func genericDrinkCalculation(_ ingredient: Ingredient) {
        let genericDrink = calculator.calculateStandardDrinks([ingredient])
        #expect(genericDrink == 1)
    }
    
    @Test("Calculate standard drinks for a martini") func calculateMartini() {
        let martini = calculator.calculateStandardDrinks(
            [
                Ingredient(volume: "2.0", strength: "40"),
                Ingredient(volume: "1.0", strength: "18")
            ]
        )
        #expect(Formatter.formatDecimal(martini) == "1.6")
    }
    
    @Test("Calculate standard drinks for a daiquiri") func calculateDaiquiri() {
        let daiquiri = calculator.calculateStandardDrinks([Ingredient(volume: "2", strength: "41.2")])
        #expect(Formatter.formatDecimal(daiquiri) == "1.4")
    }
    
    @Test("Calculate standard drinks for a Jet Pilot") func calculateJetPilot() {
        let jetPilot = calculator.calculateStandardDrinks(
            [
                Ingredient(volume: "1", strength: "40"),
                Ingredient(volume: "0.75", strength: "40"),
                Ingredient(volume: "0.75", strength: "69"),
                Ingredient(volume: "0.5", strength: "18"),
                Ingredient(volume: "0.02", strength: "50")
            ]
            
        )
        #expect(Formatter.formatDecimal(jetPilot) == "2.2")
    }
    
    @Test("Calculate ounces of one standard drink for 40% ABV")
    func calculateOuncesForFortyPercentAlcohol() {
        let ingredient = Ingredient(volume: "", strength: "40.0")
        let volume = calculator.volumeForOneStandardDrink(ingredient)
        #expect(Formatter.formatDecimal(volume) == "1.5")
    }
    
    @Test("Calculate mililiters of one standard drink for 40% ABV")
    func calculateMililitersForFortyPercentAlcohol() {
        let ingredient = Ingredient(volume: "", strength: "40.0", isMetric: true)
        let mililiters = calculator.volumeForOneStandardDrink(ingredient)
        #expect(Formatter.formatDecimal(mililiters) == "44.4")
    }
    
    @Test("Calculate volume of one standard drink for 9% ABV")
    func calculateOuncesForNinePercentAlcohol() {
        let ingredient = Ingredient(volume: "", strength: "9.0")
        let ounces = calculator.volumeForOneStandardDrink(ingredient)
        #expect(Formatter.formatDecimal(ounces) == "6.7")
    }
    
    @Test("Calculate volume of one standard drink for 14% ABV")
    func calculateOuncesForFourteenPercentAlcohol() {
        let ingredient = Ingredient(volume: "", strength: "14.0")
        let ounces = calculator.volumeForOneStandardDrink(ingredient)
        #expect(Formatter.formatDecimal(ounces) == "4.3")
    }
    
    @Test("Test filtering out empty ingredient")
    func filterOutEmptyIngredient() {
        let validIngredient = Ingredient(volume: "2", strength: "40")
        let emptyIngredient = Ingredient(volume: "", strength: "")
        
        let drink = calculator.calculateStandardDrinks(
            [
                validIngredient,
                emptyIngredient
            ]
        )
        #expect(Formatter.formatDecimal(drink) == "1.3")
    }
    
    @Test("Test filtering out partly empty ingredient")
    func filterOutPartlyEmptyIngredient() {
        let validIngredient = Ingredient(volume: "2", strength: "40")
        let emptyIngredient = Ingredient(volume: "1", strength: "")
        
        let drink = calculator.calculateStandardDrinks(
            [
                validIngredient,
                emptyIngredient
            ]
        )
        #expect(Formatter.formatDecimal(drink) == "1.3")
    }
    
    @Test("Test conversion of ingredient volume from metric to imperial")
    func convertFromMetric() {
        let martini = calculator.calculateStandardDrinks(
            [
                Ingredient(volume: "60", strength: "40", isMetric: true),
                Ingredient(volume: "30", strength: "18", isMetric: true)
            ]
        )
        #expect(Formatter.formatDecimal(martini) == "1.7")
    }
}
