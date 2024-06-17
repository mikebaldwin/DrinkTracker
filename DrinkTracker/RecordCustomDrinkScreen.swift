//
//  RecordCustomDrinkScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/25/24.
//

import SwiftUI
import SwiftData

struct RecordCustomDrinkScreen: View {
    var completion: ((CustomDrink) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @Query(
        sort: \CustomDrink.name,
        order: .forward
    ) var customDrinks: [CustomDrink]
    
    @State private var showConfirmation = false
    @State private var selectedDrink: CustomDrink?
    
    private var modelContext: ModelContext
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(customDrinks) { drink in
                    Button {
                        selectedDrink = drink
                        showConfirmation = true
                    } label: {
                        HStack {
                            Text(drink.name)
                            Spacer()
                            Text(Formatter.formatDecimal(drink.standardDrinks))
                        }
                        .foregroundStyle(Color.black)
                    }
                }
                .onDelete { offsets in
                    if let first = offsets.first {
                        modelContext.delete(customDrinks[first])
                    }
                }
            }
            .navigationTitle("Whatcha drinkin?")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                        completion(selectedDrink)
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) { dismiss() }
            }
        }
    }
    
    init(modelContext: ModelContext, completion: ((CustomDrink) -> Void)?) {
        self.modelContext = modelContext
        self.completion = completion
    }
}

//#Preview {
//    RecordCustomDrinkScreen(modelContext: ModelContext(<#ModelContainer#>))
//}
