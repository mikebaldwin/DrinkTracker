//
//  DrinksHistoryScreenWatch.swift
//  Watch
//
//  Created by Mike Baldwin on 7/8/24.
//

import SwiftUI

import SwiftData
import SwiftUI

struct DrinksHistoryScreenWatch: View {
    @Query(
        sort: \DrinkRecord.timestamp,
        order: .reverse
    ) var drinkRecords: [DrinkRecord]
    
    @State private var days: [Day] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(days) { day in
                    Section(formatDate(day.date)) {
                        if day.drinks.isEmpty {
                            Text("Alcohol-free")
                        } else {
                            ForEach(day.drinks, id: \.id) { drink in
                                HStack {
                                    Text(formatTimestamp(drink.timestamp))
                                    Spacer()
                                    Text(Formatter.formatDecimal(drink.standardDrinks))
                                }
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
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.component(.year, from: date) < calendar.component(.year, from: now) {
            dateFormatter.dateFormat = "E, MMM d, yyyy"
        } else {
            dateFormatter.dateFormat = "E, MMM d"
        }
        
        return dateFormatter.string(from: date)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    private func buildDays() {
        days.removeAll()
        
        var dayDictionary = [Date: [DrinkRecord]]()
        let calendar = Calendar.current

        // Iterate through the drinkRecords and populate the dayDictionary
        for record in drinkRecords {
            let startOfDay = calendar.startOfDay(for: record.timestamp)
            dayDictionary[startOfDay, default: []].append(record)
        }

        // Identify the earliest date in drinkRecords
        let earliestDate = drinkRecords.min {
            $0.timestamp < $1.timestamp
        }?.timestamp ?? Date()

        // "current" as in current iteration, not current as in today
        var currentDate = earliestDate
        let startOfTomorrow = Date.tomorrow
        
        // Create an array of Day objects for all days in the sequence
        while currentDate <= startOfTomorrow {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let drinks = dayDictionary[startOfDay] ?? []
            let day = Day(date: startOfDay, drinks: drinks)
            days.append(day)
            
            currentDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            )!
        }

        // Sort the days array by date
        days.sort { $0.date > $1.date }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self,
        configurations: config
    )

    DrinksHistoryScreenWatch()
        .modelContainer(container)
}
