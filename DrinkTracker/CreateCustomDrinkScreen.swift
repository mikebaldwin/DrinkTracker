//
//  CreateCustomDrinkScreen.swift
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
    @State private var totalStandardDrinks = 0.0
    
    var body: some View {
        NavigationStack {
            Form {
                // Drink name section
                Section {
                    TextField("Drink Name", text: $nameText)
                    Text("\(Formatter.formatDecimal(totalStandardDrinks)) total standard \(totalStandardDrinks == 1 ? "drink" : "drinks")")
                }
                
                // Ingredients entry section
                if !ingredients.isEmpty {
                    ForEach($ingredients) { ingredient in
                        Section() {
                            IngredientCell(ingredient: ingredient) {
                                updateTotalStandardDrinks()
                            }
                        }
                    }
                    .onDelete { offsets in
                        withAnimation {
                            if let first = offsets.first {
                                ingredients.remove(at: first)
                                updateTotalStandardDrinks()
                            }
                        }
                    }
                }
                
                // Ingredient control section
                Section {
                    HStack {
                        Button {
                            withAnimation {
                                ingredients.append(Ingredient(volume: "", abv: ""))
                            }
                        } label: {
                            Text("Add Ingredient")
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
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
                    .disabled(!formIsValid())
                }
            }
            .onAppear {
                ingredients.append(Ingredient(volume: "", abv: ""))
            }
        }
    }
    
    private func updateTotalStandardDrinks() {
        totalStandardDrinks = DrinkCalculator().calculateStandardDrinks(ingredients)
    }
    
    private func addIngredient(_ ingredient: Ingredient) {
        withAnimation {
            ingredients.append(ingredient)
            updateTotalStandardDrinks()
        }
    }
    
    private func formIsValid() -> Bool {
        if ingredients.first(where: { $0.isValid }) != nil {
            return true
        }
        return false
    }
}

#Preview {
    CreateCustomDrinkScreen()
}
