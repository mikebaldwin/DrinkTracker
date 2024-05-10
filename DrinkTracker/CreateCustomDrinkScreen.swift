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
    @State private var showDrinkEntryAlert = false
    @State private var totalStandardDrinks = 0.0
    
    @State private var newVolume = ""
    @State private var newAbv = ""
    
    private var isValid: Bool {
        !nameText.isEmpty && !ingredients.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Drink name section
                Section {
                    TextField("Drink Name", text: $nameText)
                    if totalStandardDrinks > 0 {
                        Text("\(Formatter.formatDecimal(totalStandardDrinks)) standard drinks")
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
                        .onDelete { offsets in
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
                            showDrinkEntryAlert = true
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
                    .disabled(!isValid)
                }
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
    
    private func updateTotalStandardDrinks() {
        totalStandardDrinks = DrinkCalculator().calculateStandardDrinks(ingredients)
    }
    
    private func addIngredient(_ ingredient: Ingredient) {
        withAnimation {
            ingredients.append(ingredient)
            updateTotalStandardDrinks()
        }
    }
}

#Preview {
    CreateCustomDrinkScreen()
}
