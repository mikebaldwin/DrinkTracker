//
//  ContentView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI
import SwiftData

struct MainScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recordedDrinks: [Drink]
    @State var showRecordDrinkScreen = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Drinks today: 3")
                }
                Section {
                    Button(action: {
                        showRecordDrinkScreen = true
                    }, label: {
                        Text("Record Drink")
                    })
                }
            }
        }
        .sheet(isPresented: $showRecordDrinkScreen) {
            RecordDrinkScreen()
        }
    }

    private func addItem() {
        withAnimation {
//            let newItem = Drink(standardDrinks: <#T##Double#>, name: <#T##String?#>)
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recordedDrinks[index])
            }
        }
    }
}

#Preview {
    MainScreen()
        .modelContainer(for: Drink.self, inMemory: true)
}
