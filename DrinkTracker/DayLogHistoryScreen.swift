//
//  DayLogHistoryScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/8/24.
//

import SwiftData
import SwiftUI

struct DayLogHistoryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DrinkRecord.timestamp, order: .reverse) var drinkRecords: [DrinkRecord]
    
    @State private var days: [Day] = []
    private var healthStoreManager = HealthStoreManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(days) { day in
                    Section(formatDate(day.date)) {
                        if day.drinks.isEmpty {
                            Text("Alcohol-free")
                        } else {
                            ForEach(day.drinks, id: \.id) { drink in
                                NavigationLink {
                                    DrinkRecordDetailScreen(drinkRecord: drink) { drinkRecord, newDate in
                                        update(drinkRecord, with: newDate)
                                    }
                                } label: {
                                    HStack {
                                        Text(formatTimestamp(drink.timestamp))
                                        Spacer()
                                        Text(Formatter.formatDecimal(drink.standardDrinks))
                                    }
                                }
                            }
                            .onDelete { offsets in
                                delete(from: day.drinks, at: offsets)
                            }
                            if day.drinks.count > 1 {
                                HStack {
                                    Text("Total")
                                    Spacer()
                                    Text(Formatter.formatDecimal(day.totalDrinks))
                                }
                                .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Drink History")
        .onAppear {
            buildDays()
        }
    }
    
    private let dateFormatter = DateFormatter()
    
    private func formatDate(_ date: Date) -> String {
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    private func buildDays() {
        days.removeAll()
        
        var dayDictionary = [Date: [DrinkRecord]]()

        // Iterate through the drinkRecords and populate the dayDictionary
        for record in drinkRecords {
            let startOfDay = Calendar.current.startOfDay(for: record.timestamp)
            dayDictionary[startOfDay, default: []].append(record)
        }

        // Identify the earliest date in drinkRecords
        let earliestDate = drinkRecords.min {
            $0.timestamp < $1.timestamp
        }?.timestamp ?? Date()

        // "current" as in current iteration, not current as in today
        var currentDate = earliestDate
        let startOfTomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: Date()
            )!
        )
        
        // Create an array of Day objects for all days in the sequence
        while currentDate <= startOfTomorrow {
            let startOfDay = Calendar.current.startOfDay(for: currentDate)
            let drinks = dayDictionary[startOfDay] ?? []
            let day = Day(date: startOfDay, drinks: drinks)
            days.append(day)
            
            currentDate = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            )!
        }

        // Sort the days array by date
        days.sort { $0.date > $1.date }
    }
    
    private func update(_ drinkRecord: DrinkRecord, with newDate: Date) {
        let calendar = Calendar.current
        
        // This part is purely local to this view; no entity data is actually changed
        // grab the old date now for updating healthkit later
        let oldDate = drinkRecord.timestamp
        
        // Remove drink from its original day
        if var oldDay = days.first(where: { oldDay in
            calendar.isDate(oldDay.date, inSameDayAs: oldDate)
        }) {
            oldDay.removeDrink(drinkRecord)
        }
        
        // Add drink to its new day
        if var newDay = days.first(where: { newDay in
            calendar.isDate(newDay.date, inSameDayAs: newDate)
        }) {
            newDay.addDrink(drinkRecord)
        } else {
            // Day wasn't found, so create it
            var newDay = Day(date: calendar.startOfDay(for: newDate))
            newDay.addDrink(drinkRecord)
            days.append(newDay)
            days.sort { $0.date > $1.date }
        }
        
        // Update the drink record
        drinkRecord.timestamp = newDate
        
        // Update in healthkit
        Task {
            do {
                try await healthStoreManager.updateAlcoholicBeverageDate(
                    newDate,
                    withUUID: UUID(uuidString: drinkRecord.id)!
                )
                debugPrint("✅ Date reassigned in HealthKit!")
            } catch {
                debugPrint("🛑 Failed to assign drink to new day: \(error.localizedDescription)")
            }
        }
    }
    
    private func delete(from drinks: [DrinkRecord], at offsets: IndexSet) {
        if let index = offsets.first {
            let drinkRecord = drinks[index]
            modelContext.delete(drinkRecord)
            buildDays()
            
            Task {
                do {
                    try await healthStoreManager.deleteAlcoholicBeverage(withUUID: UUID(uuidString: drinkRecord.id)!)
                    debugPrint("✅ Deleted from HealthKit!")
                } catch {
                    debugPrint("🛑 Failed to delete from HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
}

//#Preview {
//    DayLogHistoryScreen()
//}
