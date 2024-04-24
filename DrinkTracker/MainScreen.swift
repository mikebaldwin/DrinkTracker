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
    @State private var showRecordDrinkScreen = false
    @State private var drinkCount = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Drinks today: 3")
                }
                Section {
                    VStack {
                        recordDrinkView
                            .padding(.bottom)
                        HStack {
                            Spacer()
                            Button {
                                
                            } label: {
                                
                                Text("Record Drink")
                            }
                            Spacer()
                        }
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button {
                            showRecordDrinkScreen = true
                        } label: {
                            Text("Record drink from catalog")
                        }
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $showRecordDrinkScreen) {
            RecordDrinkScreen()
        }
    }
    
    private var recordDrinkView: some View {
        HStack {
            Spacer()
            
            Button {
                if drinkCount > 0 {
                    drinkCount -= 1
                    debugPrint("decrement drinkCount")
                }
            } label: {
                Image(systemName: "minus.circle")
                    .font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("\(drinkCount)")
                .font(.largeTitle)
                .padding(
                    EdgeInsets(
                        top: 0,
                        leading: 20,
                        bottom: 0,
                        trailing: 20
                    )
                )
            
            Button {
                drinkCount += 1
                debugPrint("increment drinkCount")
            } label: {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
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
