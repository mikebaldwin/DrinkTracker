//
//  IngredientCell.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/24/24.
//

import SwiftUI

enum Measurement {
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
    @Binding var ingredient: Ingredient
    
    var onUpdate: (() -> Void)
    
    @State private var abv = ""
    @State private var alcoholMeasurement: AlcoholMeasurement = .abv
    @State private var measurement: Measurement = .imperial
    @State private var standardDrinks = 0.0
    @State private var volume = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField(measurement.title, text: $volume)
                    .keyboardType(.decimalPad)
                    .onChange(of: volume) {
                        ingredient.volume = volume
                        calculate()
                    }
                Picker("Measurement System", selection: $measurement) {
                    Text("Imperial").tag(Measurement.imperial)
                    Text("Metric").tag(Measurement.metric)
                }
                .pickerStyle(.segmented)
            }
            
            Divider()
            
            HStack {
                TextField("ABV %", text: $abv)
                    .keyboardType(.decimalPad)
                    .onChange(of: abv) {
                        ingredient.abv = abv
                        calculate()
                    }
                Picker("Alcohol Measurement", selection: $alcoholMeasurement) {
                    Text("ABV %").tag(AlcoholMeasurement.abv)
                    Text("Proof").tag(AlcoholMeasurement.proof)
                }
                .pickerStyle(.segmented)
            }
            Text("\(Formatter.formatDecimal(standardDrinks)) standard drinks")
                .font(.caption)
                .padding(.top)
        }
    }
    
    private func calculate() {
        if ingredient.isValid {
            standardDrinks = DrinkCalculator().calculateStandardDrinks([ingredient])
            onUpdate()
        }
    }
}

//#Preview {
//    IngredientCell(ingredient: Binding(projectedValue: Ingredient(volume: "", abv: "")))
//}