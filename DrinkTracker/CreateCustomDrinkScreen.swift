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
    @State private var showDrinkEntryAlert = false
    @State private var totalStandardDrinks = 0.0
    
    @State private var newVolume = ""
    @State private var newAbv = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Drink name section
                Section {
                    TextField("Drink Name", text: $nameText)
                    if totalStandardDrinks > 0 {
                        Text("\(Formatter.formatDecimal(totalStandardDrinks)) standard drinks")
                    } else {
                        Text("Add ingredients to calculate standard drinks")
                            .foregroundStyle(Color.gray)
                    }
                }
                
                // Ingredients entry section
                if !ingredients.isEmpty {
                    Section("Ingredients") {
                        ForEach($ingredients) { ingredient in
                            HStack {
                                Text("Volume: \(ingredient.volume.wrappedValue)")
                                Spacer()
                                Text("ABV: \(ingredient.abv.wrappedValue)")
                            }
                        }
                    }
                }
                
                // Ingredient control section
                Section {
                    GeometryReader { geometry in
                        HStack {
                            Button {
                                showDrinkEntryAlert = true
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
        .alert("Enter drink details", isPresented: $showDrinkEntryAlert) {
            TextField("", text: $newVolume, prompt: Text("Volume"))
                .keyboardType(.decimalPad)
            TextField("", text: $newAbv, prompt: Text("ABV"))
                .keyboardType(.decimalPad)
            
            Button("Cancel", role: .cancel) {
                showDrinkEntryAlert = false
            }
            Button("Done") {
                addIngredient(Ingredient(volume: newVolume, abv: newAbv))
                showDrinkEntryAlert = false
                newVolume = ""
                newAbv = ""
            }
        }
    }
    
    private func calculateStandardDrinks(_ ingredients: [Ingredient]) -> Double {
        let result = DrinkCalculator().calculateStandardDrinks(ingredients)
        return result
    }
    
    private func addIngredient(_ ingredient: Ingredient) {
        withAnimation {
            ingredients.append(ingredient)
            totalStandardDrinks = calculateStandardDrinks(ingredients)
        }
    }
}

#Preview {
    CreateCustomDrinkScreen()
}
