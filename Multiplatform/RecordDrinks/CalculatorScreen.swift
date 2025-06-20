//
//  CalculatorScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct CalculatorScreen: View {
    var createCustomDrink: ((CustomDrink) -> Void)?
    var createDrinkRecord: ((DrinkRecord) -> Void)?
    
    @Environment(\.dismiss) private var dismiss

    @State private var nameText = ""
    @State private var ingredients = [Ingredient]()
    @State private var totalStandardDrinks = 0.0
    @State private var showDoneConfirmation = false
    @State private var showRecordDrinkConfirmation = false
    @State private var showNameDrinkAlert = false
    @State private var nameDrinkValue = ""
    
    var body: some View {
        NavigationStack {
            Form {
                drinkTotalSection
                
                if !ingredients.isEmpty {
                    ingredientEntrySection
                }
                
                addIngredientSection
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showDoneConfirmation = true
                    } label: {
                        Text("Done")
                    }
                    .disabled(!formIsValid())
                }
            }
            .onAppear {
                ingredients.append(Ingredient(volume: "", strength: ""))
            }
        }
        .confirmationDialog(
            "Choose what to do with this drink",
            isPresented: $showDoneConfirmation,
            titleVisibility: .hidden
        ) {
            Button("Record Drink") {
                if let createDrinkRecord {
                    createDrinkRecord(DrinkRecord(standardDrinks: totalStandardDrinks))
                }
                dismiss()
            }
            Button("Create Custom Drink") {
                showNameDrinkAlert = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog(
            "Are you drinking it now?",
            isPresented: $showRecordDrinkConfirmation,
            titleVisibility: .visible
        ) {
            Button("Record Drink") {
                if let createDrinkRecord {
                    createDrinkRecord(DrinkRecord(standardDrinks: totalStandardDrinks))
                }
                dismiss()
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .alert("Give this drink a name", isPresented: $showNameDrinkAlert) {
            TextField("", text: $nameDrinkValue)
            
            Button("Cancel", role: .cancel) {
                nameDrinkValue = ""
            }
            Button("Done") {
                if let createCustomDrink {
                    createCustomDrink(
                        CustomDrink(
                            name: nameDrinkValue,
                            standardDrinks: totalStandardDrinks
                        )
                    )
                }
                nameDrinkValue = ""
                showRecordDrinkConfirmation = true
            }
        }
    }
    
    private var drinkTotalSection: some View {
        Section {
            Text("\(Formatter.formatDecimal(totalStandardDrinks)) total standard \(totalStandardDrinks == 1 ? "drink" : "drinks")")
        }
    }
    
    private var ingredientEntrySection: some View {
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
    
    private var addIngredientSection: some View {
        Section {
            HStack {
                Button {
                    withAnimation {
                        ingredients.append(Ingredient(volume: "", strength: ""))
                    }
                } label: {
                    Text("Add Ingredient")
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
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
    CalculatorScreen()
}
