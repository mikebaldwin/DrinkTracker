//
//  RecordCatalogDrinkScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/25/24.
//

import SwiftUI
import SwiftData

struct RecordCatalogDrinkScreen: View {
    var completion: ((Drink) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Query(
        sort: \CatalogDrink.name,
        order: .forward
    ) var catalogDrinks: [CatalogDrink]
    @State private var showConfirmation = false
    @State private var selectedDrink: CatalogDrink?
    
    var body: some View {
        List {
            ForEach(catalogDrinks) { drink in
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
        }
        .confirmationDialog(
            "Record \(selectedDrink?.name ?? "this") to today's drinks?",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Record Drink", role: .destructive) {
                if let selectedDrink, let completion {
                    completion(Drink(selectedDrink))
                }
            }
            Button("Cancel") { dismiss() }
        }
    }
}

#Preview {
    RecordCatalogDrinkScreen()
}
