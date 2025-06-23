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

    @AppStorage("useMetricAsDefault") private var useMetricAsDefault = false
    @AppStorage("useProofAsDefault") private var useProofAsDefault = false

    @Binding var ingredient: Ingredient
    @FocusState private var volumeFieldFocus: Field?

    var onUpdate: (() -> Void)
    
    @State private var strength = ""
    // TODO: set to choice from userdefaults
    @State private var alcoholStrength: AlcoholStrength = .abv
    // TODO: set to choice from userdefaults
    @State private var volumeMeasurement: VolumeMeasurement = .imperial
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
            
            if useMetricAsDefault {
                volumeMeasurement = .metric
            }
            if useProofAsDefault {
                alcoholStrength = .proof
            }
        }
    }
    
    private var volumeCell: some View {
        HStack {
            TextField(
                showCalcShortcut ? calcShortcutTitle : volumeMeasurement.title,
                text: $volume
            )
            .keyboardType(.decimalPad)
            .onChange(of: volume) {
                showCalcShortcut = false
                ingredient.volume = volume
                calculate()
            }
            .onChange(of: volumeMeasurement) {
                ingredient.isMetric = (volumeMeasurement == .metric)
                calculate()
            }
            .focused($volumeFieldFocus, equals: .volume)
            .accessibilityLabel("Volume amount")
            .accessibilityHint("Enter the volume of this ingredient")
            .accessibilityValue(volume.isEmpty ? "No value entered" : "\(volume) \(volumeMeasurement.title)")
            
            Picker("Volume Measurement", selection: $volumeMeasurement) {
                Text("oz").tag(VolumeMeasurement.imperial)
                    .accessibilityLabel("Ounces")
                Text("ml").tag(VolumeMeasurement.metric)
                    .accessibilityLabel("Milliliters")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Volume unit")
            .accessibilityHint("Choose between ounces and milliliters")
        }
    }
    
    private var strengthCell: some View {
        HStack {
            TextField(
                alcoholStrength.title,
                text: $strength
            )
                .keyboardType(.decimalPad)
                .onChange(of: strength) {
                    ingredient.strength = strength
                    showCalcShortcut = !strength.isEmpty
                    calculate()
                }
                .onChange(of: alcoholStrength) {
                    ingredient.isProof = (alcoholStrength == .proof)
                    calculate()
                }
                .accessibilityLabel("Alcohol strength")
                .accessibilityHint("Enter the alcohol percentage or proof")
                .accessibilityValue(strength.isEmpty ? "No value entered" : "\(strength) \(alcoholStrength.title)")
            Picker("Alcohol Strength", selection: $alcoholStrength) {
                Text("ABV %").tag(AlcoholStrength.abv)
                    .accessibilityLabel("Alcohol by volume percentage")
                Text("Proof").tag(AlcoholStrength.proof)
                    .accessibilityLabel("Proof measurement")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Alcohol strength unit")
            .accessibilityHint("Choose between ABV percentage and proof")
        }
    }
    
    private var ingredientTotalView: some View {
        Text("\(Formatter.formatDecimal(standardDrinks)) standard \(standardDrinks == 1 ? "drink" : "drinks")")
            .font(.caption)
            .padding(.top)
            .accessibilityLabel("Calculated result")
            .accessibilityValue("\(Formatter.formatDecimal(standardDrinks)) standard drinks for this ingredient")
    }
    
    private func calculate() {
        let calculator = DrinkCalculator()
        
        if ingredient.isValid {
            standardDrinks = calculator.calculateStandardDrinks([ingredient])
        } else if ingredient.hasOnlyABV {
            let volume = calculator.volumeForOneStandardDrink(ingredient)
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
