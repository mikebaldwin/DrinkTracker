//
//  ContentView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Charts
import SwiftUI

struct MainScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(DrinkTrackerModel.self) private var model
    
    @State private var showRecordDrinksConfirmation = false
    @State private var showRecordCustomDrinkScreen = false
    @State private var drinkCount = 1.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ChartView()
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
        }
        .sheet(isPresented: $showRecordCustomDrinkScreen) {
            RecordCatalogDrinkScreen {
                model.recordDrink(DrinkRecord($0))
            }
        }
        .confirmationDialog(
            "Add \(Formatter.formatDecimal(drinkCount)) drinks to today's record?",
            isPresented: $showRecordDrinksConfirmation,
            titleVisibility: .visible
        ) {
            Button("Record Drink") {
                model.recordDrink(
                    DrinkRecord(
                        standardDrinks: Double(drinkCount),
                        name: "Quick Record"
                    )
                )
                model.refresh()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                model.refresh()
            }
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
            
            Text("\(Formatter.formatDecimal(drinkCount))")
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
}

#Preview {
    MainScreen()
        .modelContainer(for: DrinkRecord.self, inMemory: true)
}
