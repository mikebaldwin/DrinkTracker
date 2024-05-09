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
    @Query(sort: \DayLog.date, order: .reverse) var dayLogs: [DayLog]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dayLogs) { dayLog in
                    Section(formatDate(dayLog.date)) {
                        if dayLog.drinks!.isEmpty {
                            Text("Alcohol-free")
                        } else {
                            if let drinks = dayLog.drinks?.sorted(by: { $0.timestamp < $1.timestamp }) {
                                ForEach(drinks, id: \.timestamp) { drink in
                                    NavigationLink {
                                        DrinkRecordDetailScreen(drinkRecord: drink) { drinkRecord, newDate in
                                            if let oldDayLog = dayLogs.first(where: { oldDayLog in
                                                Calendar.current.isDate(oldDayLog.date, inSameDayAs: drinkRecord.timestamp)
                                            }) {
                                                oldDayLog.removeDrink(drinkRecord)
                                            }
                                            if let newDayLog = dayLogs.first(where: { newDayLog in
                                                Calendar.current.isDate(newDayLog.date, inSameDayAs: newDate)
                                            }) {
                                                newDayLog.addDrink(drinkRecord)
                                                drinkRecord.timestamp = newDate
                                            }
                                        }
                                    } label: {
                                        VStack {
                                            HStack {
                                                Text(formatTimestamp(drink.timestamp))
                                                Spacer()
                                                Text(Formatter.formatDecimal(drink.standardDrinks))
                                            }
                                            Text(drink.id)
                                                .font(.footnote)
                                        }
                                    }
                                }
                                if dayLog.drinks!.count > 1 {
                                    HStack {
                                        Text("Total")
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text(Formatter.formatDecimal(dayLog.totalDrinks))
                                    }
                                }
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    if let first = offsets.first {
                        withAnimation {
                            modelContext.delete(dayLogs[first])
                        }
                    }
                }
            }
        }
        .navigationTitle("Drink History")
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
}

//#Preview {
//    DayLogHistoryScreen()
//}
