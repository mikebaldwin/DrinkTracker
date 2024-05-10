//
//  ContentView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Charts
import HealthKitUI
import SwiftData
import SwiftUI

struct MainScreen: View {
    @AppStorage("dailyTarget") private var dailyTarget: Double?
    @AppStorage("weeklyTarget") private var weeklyTarget: Double?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(HealthStoreManager.self) private var healthStoreManager
    
    @Query(sort: [SortDescriptor(\DayLog.date)]) private var dayLogs: [DayLog]
    
    @State private var showRecordDrinksConfirmation = false
    @State private var showRecordCustomDrinkScreen = false
    @State private var showSettingsScreen = false
    @State private var showDrinkEntryAlert = false
    @State private var drinkCount = 0.0
    @State private var quickEntryValue = ""
    
    private var todaysLog: DayLog {
        if let todaysLog = dayLogs.last, Calendar.current.isDateInToday(todaysLog.date) {
            return todaysLog
        } else {
            let dayLog = DayLog()
            modelContext.insert(dayLog)
            try? modelContext.save()
            return dayLog
        }
    }
    private var thisWeeksLogs: [DayLog] {
        dayLogs.filter { $0.date >= DateMath.startOfWeek && $0.date < DateMath.endOfWeek }
    }
    private var totalStandardDrinksToday: Double { todaysLog.totalDrinks }
    private var totalStandardDrinksThisWeek: Double {
        thisWeeksLogs.reduce(into: 0.0) { partialResult, dayLog in
            partialResult += dayLog.totalDrinks
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Drinks") {
                    ChartView(
                        dayLogs: thisWeeksLogs,
                        totalStandardDrinksToday: totalStandardDrinksToday,
                        totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
                    )
                }
                if dailyTarget != nil || weeklyTarget != nil {
                    Section("Targets") {
                        if let dailyTarget {
                            HStack {
                                Text("Today")
                                    .fontWeight(.semibold)
                                Spacer()
                                if totalStandardDrinksToday < dailyTarget {
                                    let drinksRemaining = dailyTarget - totalStandardDrinksToday
                                    let noun = drinksRemaining > 1 ? "drinks" : "drink"
                                    Text("\(Formatter.formatDecimal(drinksRemaining)) \(noun) below target")
                                } else if totalStandardDrinksToday == dailyTarget {
                                    Text("Daily target reached!")
                                } else {
                                    let drinksOverTarget = totalStandardDrinksToday - dailyTarget
                                    let noun = drinksOverTarget > 1 ? "drinks" : "drink"
                                    Text("\(Formatter.formatDecimal(drinksOverTarget)) \(noun) above target")
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
                                if totalStandardDrinksThisWeek < weeklyTarget {
                                    Text("\(Formatter.formatDecimal(weeklyTarget - totalStandardDrinksThisWeek)) drinks below target")
                                } else if totalStandardDrinksThisWeek == weeklyTarget {
                                    Text("Daily target reached!")
                                } else {
                                    Text("\(Formatter.formatDecimal(totalStandardDrinksThisWeek - weeklyTarget)) drinks above target")
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
            RecordCustomDrinkScreen(modelContext: modelContext) {
                recordDrink(DrinkRecord($0))
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
                recordDrink(
                    DrinkRecord(
                        standardDrinks: Double(drinkCount),
                        name: "Untitled Drink"
                    )
                )
                _ = dayLogs
                drinkCount = 0
            }
            Button("Cancel", role: .cancel) { drinkCount = 0 }
        }
        .alert("Enter standard drinks", isPresented: $showDrinkEntryAlert) {
            TextField("", text: $quickEntryValue)
                .keyboardType(.decimalPad)
            
            Button("Cancel", role: .cancel) {
                showDrinkEntryAlert = false
                quickEntryValue = ""
            }
            Button("Done") {
                if let value = Double(quickEntryValue) {
                    drinkCount = value
                }
                showDrinkEntryAlert = false
                showRecordDrinksConfirmation = true
                quickEntryValue = ""
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                _ = dayLogs
            }
        }
    }
    
    private var recordDrinkView: some View {
        HStack {
            Spacer()
            
            Button {
                if drinkCount > 0 {
                    withAnimation {
                        drinkCount -= 1.0
                    }
                    debugPrint("decrement drinkCount")
                }
            } label: {
                Image(systemName: "minus.circle")
                    .font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                showDrinkEntryAlert = true
            } label: {
                Text("\(Formatter.formatDecimal(drinkCount))")
                    .font(.largeTitle)
                    .frame(width: 75)
                    .foregroundStyle(Color.black)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                withAnimation {
                    drinkCount += 1.0
                }
                debugPrint("increment drinkCount")
            } label: {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding(.top)
    }
    
    private func addCatalogDrink(_ catalogDrink: CustomDrink) {
        modelContext.insert(catalogDrink)
    }
    
    private func recordDrink(_ drink: DrinkRecord) {
        todaysLog.addDrink(drink)
        Task {
            do {
                try await healthStoreManager.save(
                    standardDrinks: drink.standardDrinks,
                    for: drink.timestamp
                )
                debugPrint("✅ Drink saved to HealthKit on \(drink.timestamp)")
            } catch {
                debugPrint("🛑 Failed to save drink to HealthKit: \(error.localizedDescription)")
            }
        }
    }

}

#Preview {
    MainScreen()
        .modelContainer(previewContainer)
}
