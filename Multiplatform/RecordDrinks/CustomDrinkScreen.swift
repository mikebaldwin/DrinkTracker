//
//  CustomDrinkScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/25/24.
//

import SwiftUI
import SwiftData

struct CustomDrinkScreen: View {
    var completion: ((CustomDrink) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \CustomDrink.name,
        order: .forward
    ) var customDrinks: [CustomDrink]
    
    @State private var showConfirmation = false
    @State private var searchText = ""
    @State private var selectedDrink: CustomDrink?
    
    private var searchResults: [CustomDrink] {
        if searchText.isEmpty {
            return customDrinks
        }
        return customDrinks.filter { $0.name.contains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults) { drink in
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
                Button("Cancel", role: .cancel) {
                    // Dismiss dialog
                }
            }
        }
        .searchable(text: $searchText)
    }
}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(
//        for: DrinkRecord.self,
//        configurations: config
//    )
//
//    CustomDrinkScreen(completion: { _ in })
//        .modelContainer(container)
//}
