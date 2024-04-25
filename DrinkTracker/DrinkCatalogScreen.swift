//
//  DrinkCatalogScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct DrinkCatalogScreen: View {
    var completion: ((CatalogDrink) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var nameText = ""
    @State private var standardDrinks = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Drink Name", text: $nameText)
                    TextField("Standard Drinks", text: $standardDrinks)
                        .keyboardType(.decimalPad)
                }
                Section {
                    HStack {
                        Spacer()
                        Button {
                            if let completion,
                                let standardDrinks = Double(standardDrinks) {
                                completion(
                                    CatalogDrink(
                                        name: nameText,
                                        standardDrinks: Double(standardDrinks)
                                    )
                                )
                            }
                        } label: {
                            Text("Add Drink to Catalog")
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Create a Drink")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

#Preview {
    DrinkCatalogScreen()
}
