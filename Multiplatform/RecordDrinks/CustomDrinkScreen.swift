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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Custom drink: \(drink.name)")
                    .accessibilityValue("\(Formatter.formatDecimal(drink.standardDrinks)) standard drinks")
                    .accessibilityHint("Tap to record this drink")
                }
                .onDelete { offsets in
                    if let first = offsets.first {
                        let drinkToDelete = customDrinks[first]
                        modelContext.delete(drinkToDelete)
                        UIAccessibility.post(notification: .announcement, argument: "Deleted \(drinkToDelete.name)")
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
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Closes custom drinks without selecting one")
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
                .accessibilityLabel("Record \(selectedDrink?.name ?? "drink")")
                .accessibilityHint("Records \(selectedDrink?.name ?? "this drink") to today's total")
                
                Button("Cancel", role: .cancel) {
                    // Dismiss dialog
                }
                .accessibilityLabel("Cancel recording")
                .accessibilityHint("Cancels recording and returns to custom drinks list")
            }
        }
        .searchable(text: $searchText)
        .accessibilityLabel("Search custom drinks")
        .accessibilityHint("Filter saved drinks by name")
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
