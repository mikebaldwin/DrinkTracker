//
//  CalculatorScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI
import SwiftData

struct CalculatorScreen: View {
    var createCustomDrink: ((CustomDrink) -> Void)?
    var createDrinkRecord: ((DrinkRecord) -> Void)?
    
    @Environment(SettingsStore.self) private var settingsStore
    
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
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Closes the calculator without saving")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showDoneConfirmation = true
                    } label: {
                        Text("Done")
                    }
                    .disabled(!formIsValid())
                    .accessibilityLabel("Done")
                    .accessibilityHint("Completes calculation and provides options to record or save drink")
                }
            }
            .onAppear {
                ingredients.append(Ingredient(volume: "", strength: ""))
            }
        }
        .confirmationDialog(
            "Choose what to do with this drink",
            isPresented: $showDoneConfirmation,
            titleVisibility: .visible
        ) {
            Button("Record Drink") {
                if let createDrinkRecord {
                    createDrinkRecord(DrinkRecord(standardDrinks: totalStandardDrinks))
                }
                dismiss()
            }
            .accessibilityLabel("Record drink now")
            .accessibilityHint("Records \(Formatter.formatDecimal(totalStandardDrinks)) drinks to today's total")
            
            Button("Create Custom Drink") {
                showNameDrinkAlert = true
            }
            .accessibilityLabel("Save as custom drink")
            .accessibilityHint("Saves this recipe for future use")
            
            Button("Cancel", role: .cancel) { }
            .accessibilityLabel("Cancel")
            .accessibilityHint("Returns to calculator without taking action")
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
            .accessibilityLabel("Yes, record drink")
            .accessibilityHint("Records the custom drink you just created to today's total")
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .accessibilityLabel("No, just save recipe")
            .accessibilityHint("Saves the custom drink recipe without recording it now")
        }
        .alert("Give this drink a name", isPresented: $showNameDrinkAlert) {
            TextField("Drink name", text: $nameDrinkValue)
                .accessibilityLabel("Drink name")
                .accessibilityHint("Enter a name for this custom drink recipe")
            
            Button("Cancel", role: .cancel) {
                nameDrinkValue = ""
            }
            .accessibilityLabel("Cancel")
            .accessibilityHint("Cancels creating custom drink")
            
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
            .accessibilityLabel("Save custom drink")
            .accessibilityHint("Saves this recipe with the entered name")
        }
    }
    
    private var drinkTotalSection: some View {
        Section {
            Text("\(Formatter.formatDecimal(totalStandardDrinks)) total standard \(totalStandardDrinks == 1 ? "drink" : "drinks")")
                .accessibilityLabel("Drink total")
                .accessibilityValue("\(Formatter.formatDecimal(totalStandardDrinks)) standard drinks")
        }
    }
    
    private var ingredientEntrySection: some View {
        ForEach($ingredients) { ingredient in
            Section() {
                IngredientCell(
                    ingredient: ingredient,
                    useMetricAsDefault: settingsStore.useMetricAsDefault,
                    useProofAsDefault: settingsStore.useProofAsDefault
                ) {
                    updateTotalStandardDrinks()
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Ingredient \(ingredients.firstIndex(where: { $0.id == ingredient.id }) ?? 0 + 1)")
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
                .accessibilityLabel("Add new ingredient")
                .accessibilityHint("Adds another ingredient field to the calculation")
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
