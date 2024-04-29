//
//  RecordCatalogDrinkScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/25/24.
//

import SwiftUI
import SwiftData

struct RecordCustomDrinkScreen: View {
    var completion: ((CustomDrink) -> Void)?
    
    @Environment(DrinkTrackerModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    
    @State private var showConfirmation = false
    @State private var showCustomDrinksEditor = false
    @State private var selectedDrink: CustomDrink?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.customDrinks) { drink in
                    Button {
                        selectedDrink = drink
                        showConfirmation = true
                    } label: {
                        Text(drink.name)
                    }
                }
            }
            .navigationTitle("Which drink?")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCustomDrinksEditor = true
                    }) {
                        Image(systemName: "wineglass")
                    }
                }
            }
            .sheet(isPresented: $showCustomDrinksEditor) {
                CreateCustomDrinkScreen {
                    model.addCatalogDrink($0)
                    model.refresh()
                }
            }
            .confirmationDialog(
                "Record \(selectedDrink?.name ?? "this") to today's drinks?",
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button("Record Drink") {
                    if let selectedDrink, let completion {
                        completion(selectedDrink)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
        .onAppear {
            model.fetchCustomDrinks()
        }
    }
}

#Preview {
    RecordCustomDrinkScreen()
}
