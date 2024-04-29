//
//  DrinkCatalogScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct DrinkCatalogScreen: View {
    var completion: ((CustomDrink) -> Void)?
    
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
                        if let completion,
                            let standardDrinks = Double(standardDrinks) {
                            completion(
                                CustomDrink(
                                    name: nameText,
                                    standardDrinks: Double(standardDrinks)
                                )
                            )
                        }
                        dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

#Preview {
    DrinkCatalogScreen()
}
