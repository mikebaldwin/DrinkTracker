//
//  ContentView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Charts
import SwiftUI
import SwiftData

struct MainScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    static var startOfWeek: Date {
        return Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date()).date!
    }

    static var endOfWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
    }

    @Query(
        filter: #Predicate<DayLog> { $0.date >= startOfWeek && $0.date < endOfWeek },
        sort: [SortDescriptor(\.date)]
    ) var dayLogs: [DayLog]
    
    @State private var showRecordDrinksConfirmation = false
    @State private var showRecordCustomDrinkScreen = false
    @State private var showCustomDrinksEditor = false
    @State private var drinkCount = 1.0
    
    private var todaysLog: DayLog {
        if let dayLog = dayLogs.first(where: { Calendar.current.isDateInToday($0.date) }) {
            return dayLog
        } else {
            let dayLog = DayLog()
            modelContext.insert(dayLog)
            return dayLog
        }
    }
    
    private var totalStandardDrinksToday: Double { todaysLog.totalDrinks }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    chartView
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
            RecordCatalogDrinkScreen {
                recordDrink(DrinkRecord($0))
            }
        }
        .confirmationDialog(
            "Add \(formatDecimal(drinkCount)) drinks to today's record?",
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                _ = dayLogs
            }
        }
    }
    
    private var chartView: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "wineglass.fill")
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Text("Drinks today: " + formatDecimal(totalStandardDrinksToday))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
            
            Chart {
                ForEach(dayLogs) { day in
                    LineMark(
                        x: .value("Date", day.date),
                        y: .value("Drinks", day.totalDrinks)
                    )
                }
            }
            .padding()
            
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
        todaysLog.addDrink(drink)
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
