//
//  IngredientCell.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/24/24.
//

import SwiftUI

enum VolumeMeasurement {
    case metric
    case imperial
    
    var title: String {
        switch self {
        case .metric: return "mililiters"
        case .imperial: return "ounces"
        }
    }
}

enum AlcoholMeasurement {
    case abv
    case proof
    
    var title: String {
        switch self {
        case .abv: return "ABV %"
        case .proof: return "Proof"
        }
    }
}

struct IngredientCell: View {
    private enum Field: Hashable {
        case volume, abv
    }

    @Binding var ingredient: Ingredient
    @FocusState private var volumeFieldFocus: Field?

    var onUpdate: (() -> Void)
    
    @State private var abv = ""
    @State private var alcoholMeasurement: AlcoholMeasurement = .abv
    @State private var measurement: VolumeMeasurement = .imperial
    @State private var standardDrinks = 0.0
    @State private var volume = ""
    @State private var showCalcShortcut = false
    @State private var calcShortcutTitle = ""
    
    var body: some View {
        VStack {
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
                
                Picker("Measurement System", selection: $measurement) {
                    Text("oz").tag(VolumeMeasurement.imperial)
                    Text("ml").tag(VolumeMeasurement.metric)
                }
                .pickerStyle(.segmented)
            }
            
            Divider()
            
            HStack {
                TextField("ABV %", text: $abv)
                    .keyboardType(.decimalPad)
                    .onChange(of: abv) {
                        ingredient.abv = abv
                        showCalcShortcut = !abv.isEmpty
                        calculate()
                    }
                Picker("Alcohol Measurement", selection: $alcoholMeasurement) {
                    Text("ABV %").tag(AlcoholMeasurement.abv)
                    Text("Proof").tag(AlcoholMeasurement.proof)
                }
                .pickerStyle(.segmented)
            }
            Text("\(Formatter.formatDecimal(standardDrinks)) standard \(standardDrinks == 1 ? "drink" : "drinks")")
                .font(.caption)
                .padding(.top)
        }
        .onAppear {
            volumeFieldFocus = .volume
        }
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
