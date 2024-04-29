//
//  ContentView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Charts
import SwiftUI

struct MainScreen: View {
    @AppStorage("dailyTarget") private var dailyTarget: Double?
    @AppStorage("weeklyTarget") private var weeklyTarget: Double?

    @Environment(\.scenePhase) private var scenePhase
    @Environment(DrinkTrackerModel.self) private var model
    
    @State private var showRecordDrinksConfirmation = false
    @State private var showRecordCustomDrinkScreen = false
    @State private var showSettingsScreen = false
    @State private var drinkCount = 1.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Progress") {
                    ChartView()
                }
                if dailyTarget != nil || weeklyTarget != nil {
                    Section("Targets") {
                        if let dailyTarget {
                            HStack {
                                Text("Today")
                                    .fontWeight(.semibold)
                                Spacer()
                                if model.totalStandardDrinksToday < dailyTarget {
                                    Text("\(Formatter.formatDecimal(dailyTarget - model.totalStandardDrinksToday)) drinks below target")
                                } else if model.totalStandardDrinksToday == dailyTarget {
                                    Text("Daily target reached!")
                                } else {
                                    Text("\(Formatter.formatDecimal(model.totalStandardDrinksToday - dailyTarget)) drinks above target")
                                        .foregroundStyle(Color(.red))
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        if let weeklyTarget {
                            HStack {
                                Text("This week")
                                    .fontWeight(.semibold)
                                Spacer()
                                if model.totalStandardDrinksThisWeek < weeklyTarget {
                                    Text("\(Formatter.formatDecimal(weeklyTarget - model.totalStandardDrinksThisWeek)) drinks below target")
                                } else if model.totalStandardDrinksThisWeek == weeklyTarget {
                                    Text("Daily target reached!")
                                } else {
                                    Text("\(Formatter.formatDecimal(model.totalStandardDrinksThisWeek - weeklyTarget)) drinks above target")
                                        .foregroundStyle(Color(.red))
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
                Section("Record") {
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
                        showSettingsScreen = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showRecordCustomDrinkScreen) {
            RecordCustomDrinkScreen {
                model.recordDrink(DrinkRecord($0))
            }
        }
        .sheet(isPresented: $showSettingsScreen) {
            SettingsScreen()
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
                model.fetchDayLogs()
            }
            Button("Cancel", role: .cancel) { }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                model.fetchDayLogs()
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

//#Preview {
//    MainScreen()
//}
