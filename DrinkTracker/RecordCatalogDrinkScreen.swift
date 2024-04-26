//
//  RecordCatalogDrinkScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/25/24.
//

import SwiftUI
import SwiftData

struct RecordCatalogDrinkScreen: View {
    var completion: ((DrinkRecord) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Query(
        sort: \CustomDrink.name,
        order: .forward
    ) var catalogDrinks: [CustomDrink]
    @State private var showConfirmation = false
    @State private var selectedDrink: CustomDrink?
    
    var body: some View {
        NavigationStack {
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
                Button("Record Drink") {
                    if let selectedDrink, let completion {
                        completion(DrinkRecord(selectedDrink))
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }
}

#Preview {
    RecordCatalogDrinkScreen()
}
