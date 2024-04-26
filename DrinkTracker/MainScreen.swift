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
    
    static var startOfDay = Calendar.current.startOfDay(for: Date())
    static var endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

    @Query(
        filter: #Predicate<DrinkRecord> {
            $0.timestamp >= startOfDay && $0.timestamp < endOfDay
        },
        sort: [SortDescriptor(\.timestamp)]
    ) var drinks: [DrinkRecord]

    @State private var showRecordDrinksConfirmation = false
    @State private var showRecordCustomDrinkScreen = false
    @State private var showCustomDrinksEditor = false
    @State private var drinkCount = 1.0
    
    private var totalStandardDrinksToday: Double {
        drinks.reduce(0) { total, drink in
            total + drink.standardDrinks
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Drinks today: " + formatDecimal(totalStandardDrinksToday))
                }
                Section {
                    VStack {
                        recordDrinkView
                            .padding(.bottom)
                        HStack {
                            Spacer()
                            Button {
                                showRecordDrinksConfirmation = true
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
                            showRecordCustomDrinkScreen = true
                        } label: {
                            Text("Record drink from catalog")
                        }
                        Spacer()
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
        }
        .sheet(isPresented: $showCustomDrinksEditor) {
            DrinkCatalogScreen { addCatalogDrink($0) }
        }
        .sheet(isPresented: $showRecordCustomDrinkScreen) {
            RecordCatalogDrinkScreen { recordDrink($0)}
        }
        .confirmationDialog(
            "Add \(drinkCount) drinks to today's record?",
            isPresented: $showRecordDrinksConfirmation,
            titleVisibility: .visible
        ) {
            Button("Record Drink") {
                recordDrink(
                    DrinkRecord(
                        standardDrinks: Double(drinkCount),
                        name: "Quick Record"
                    )
                )
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var recordDrinkView: some View {
        HStack {
            Spacer()
            
            Button {
                if drinkCount > 0 {
                    withAnimation {
                        drinkCount -= 0.5
                    }
                    debugPrint("decrement drinkCount")
                }
            } label: {
                Image(systemName: "minus.circle")
                    .font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("\(formatDecimal(drinkCount))")
                .font(.largeTitle)
                .frame(width: 75)
            
            Button {
                withAnimation {
                    drinkCount += 0.5
                }
                debugPrint("increment drinkCount")
            } label: {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
    }

    private func addCatalogDrink(_ catalogDrink: CustomDrink) {
        modelContext.insert(catalogDrink)
    }
    
    private func recordDrink(_ drink: DrinkRecord) {
        modelContext.insert(drink)
    }
    
    private func formatDecimal(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal

        return formatter.string(from: number as NSNumber) ?? "0"
    }
}

#Preview {
    MainScreen()
        .modelContainer(for: DrinkRecord.self, inMemory: true)
}
