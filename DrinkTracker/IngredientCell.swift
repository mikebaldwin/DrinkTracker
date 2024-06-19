//
//  IngredientCell.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/24/24.
//

import SwiftUI

struct IngredientCell: View {
    private enum Field: Hashable {
        case volume, abv
    }

    @Binding var ingredient: Ingredient
    @FocusState private var volumeFieldFocus: Field?

    var onUpdate: (() -> Void)
    
    @State private var abv = ""
    // TODO: set to choice from userdefaults
    @State private var alcoholMeasurement: AlcoholStrength = .abv
    // TODO: set to choice from userdefaults
    @State private var measurement: VolumeMeasurement = .imperial
    @State private var standardDrinks = 0.0
    @State private var volume = ""
    @State private var showCalcShortcut = false
    @State private var calcShortcutTitle = ""
    
    var body: some View {
        VStack {
            volumeCell
            Divider()
            strengthCell
            ingredientTotalView
        }
        .onAppear {
            volumeFieldFocus = .volume
        }
    }
    
    private var volumeCell: some View {
        HStack {
            TextField(
                showCalcShortcut ? calcShortcutTitle : measurement.title,
                text: $volume
            )
            .keyboardType(.decimalPad)
            .onChange(of: volume) {
                showCalcShortcut = false
                ingredient.volume = volume
                calculate()
            }
            .focused($volumeFieldFocus, equals: .volume)
            
            Picker("Volume Measurement", selection: $measurement) {
                Text("oz").tag(VolumeMeasurement.imperial)
                Text("ml").tag(VolumeMeasurement.metric)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var strengthCell: some View {
        HStack {
            TextField("ABV %", text: $abv)
                .keyboardType(.decimalPad)
                .onChange(of: abv) {
                    ingredient.abv = abv
                    showCalcShortcut = !abv.isEmpty
                    calculate()
                }
            Picker("Alcohol Strength", selection: $alcoholMeasurement) {
                Text("ABV %").tag(AlcoholStrength.abv)
                Text("Proof").tag(AlcoholStrength.proof)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var ingredientTotalView: some View {
        Text("\(Formatter.formatDecimal(standardDrinks)) standard \(standardDrinks == 1 ? "drink" : "drinks")")
            .font(.caption)
            .padding(.top)
    }
    
    private func calculate() {
        let calculator = DrinkCalculator()
        
        if ingredient.isValid {
            standardDrinks = calculator.calculateStandardDrinks([ingredient])
        } else if ingredient.hasOnlyABV {
            let volume = calculator.ouncesForOneStandardDrink(abv: Double(abv)!)
            calcShortcutTitle = "\(Formatter.formatDecimal(volume))"
            showCalcShortcut = true
        } else {
            standardDrinks = 0
        }
        onUpdate()
    }
}

//#Preview {
//    IngredientCell(ingredient: Binding(projectedValue: Ingredient(volume: "", abv: "")))
//}
