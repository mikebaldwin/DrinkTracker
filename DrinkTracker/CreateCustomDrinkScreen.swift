//
//  DrinkCatalogScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct CreateCustomDrinkScreen: View {
    var completion: ((CustomDrink) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var nameText = ""
    @State private var ingredients = [Ingredient]()
    @State private var showRemoveIngredientConfirmation = false
    @State private var totalStandardDrinks = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Drink Name", text: $nameText)
                    HStack {
                        Text("Standard drinks ")
                        Spacer()
                        Text(Formatter.formatDecimal(totalStandardDrinks))
                    }
                }
                ForEach($ingredients) { ingredient in
                    Section("Ingredient") {
                        TextField("Volume", text: ingredient.volume)
                            .keyboardType(.decimalPad)
                        TextField("ABV", text: ingredient.abv)
                            .keyboardType(.decimalPad)
                    }
                }
                Section {
                    GeometryReader { geometry in
                        HStack {
                            Button {
                                withAnimation {
                                    addIngredient(Ingredient(volume: "", abv: ""))
                                }
                            } label: {
                                Text("Add Ingredient")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    GeometryReader { geometry in
                        HStack {
                            Button(role: .destructive) {
                                if let ingredient = ingredients.last, ingredient.isEmpty {
                                    withAnimation {
                                        _ = ingredients.popLast()
                                    }
                                } else {
                                    showRemoveIngredientConfirmation = true
                                }
                            } label: {
                                Text("Remove ingredient")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(ingredients.count < 2)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            .navigationTitle("Create a Drink")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let completion {
                            completion(
                                CustomDrink(
                                    name: nameText,
                                    standardDrinks: totalStandardDrinks
                                )
                            )
                        }
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
            .confirmationDialog(
                "Remove this ingredient?",
                isPresented: $showRemoveIngredientConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    withAnimation {
                        _ = ingredients.popLast()
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .onAppear {
            ingredients.append(Ingredient(volume: "", abv: ""))
        }
    }
    
    private func calculateStandardDrinks(_ ingredients: [Ingredient]) -> Double {
        let result = DrinkCalculator()
            .calculateStandardDrinks(ingredients.filter { !$0.isEmpty })
        return result
    }
    
    private func addIngredient(_ ingredient: Ingredient) {
        ingredients.append(ingredient)
        totalStandardDrinks = calculateStandardDrinks(ingredients)
    }
}

#Preview {
    CreateCustomDrinkScreen()
}
