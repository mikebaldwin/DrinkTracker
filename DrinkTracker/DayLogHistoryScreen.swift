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
                        if let drinks = dayLog.drinks {
                            if drinks.isEmpty {
                                Spacer()
                                Text("0")
                            } else {
                                ForEach(drinks) { drink in
                                    HStack {
                                        Text(formatTimestamp(drink.timestamp))
                                        Spacer()
                                        Text(Formatter.formatDecimal(drink.standardDrinks))
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
        dateFormatter.dateFormat = "MMM d"
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
