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
    
    private var healthStoreManager = HealthStoreManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dayLogs) { dayLog in
                    Section(formatDate(dayLog.date)) {
                        if dayLog.drinks.isEmpty {
                            Text("Alcohol-free")
                        } else {
                            if let drinks = dayLog.drinks?.sorted(by: { $0.timestamp < $1.timestamp }) {
                                ForEach(drinks, id: \.timestamp) { drink in
                                    NavigationLink {
                                        DrinkRecordDetailScreen(drinkRecord: drink) { drinkRecord, newDate in
                                            update(drinkRecord, with: newDate)
                                        }
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(drink.name)
                                                    .font(.footnote)
                                                Text(formatTimestamp(drink.timestamp))
                                            }
                                            Spacer()
                                            Text(Formatter.formatDecimal(drink.standardDrinks))
                                        }
                                    }
                                }
                                .onDelete { offsets in
                                    delete(from: drinks, at: offsets, in: dayLog)
                                }
                                if dayLog.drinks.count > 1 {
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
    
    private func update(_ drinkRecord: DrinkRecord, with newDate: Date) {
        // grab the old date now for updating healthkit later
        let oldDate = drinkRecord.timestamp
        // Remove drink from its original dayLog
        if let oldDayLog = dayLogs.first(where: { oldDayLog in
            Calendar.current.isDate(oldDayLog.date, inSameDayAs: oldDate)
        }) {
            oldDayLog.removeDrink(drinkRecord)
        }
        // Add drink to its new dayLog
        if let newDayLog = dayLogs.first(where: { newDayLog in
            Calendar.current.isDate(newDayLog.date, inSameDayAs: newDate)
        }) {
            newDayLog.addDrink(drinkRecord)
            drinkRecord.timestamp = newDate
        } else {
            // Daylog wasn't found, so create it
            let newDayLog = DayLog(date: Calendar.current.startOfDay(for: newDate))
            newDayLog.addDrink(drinkRecord)
            drinkRecord.timestamp = newDate
        }
        // Update in healthkit
        Task {
            do {
                try await healthStoreManager.updateAlcoholicBeverageDate(
                    forDate: oldDate,
                    newDate: newDate
                )
                debugPrint("✅ Date reassigned in HealthKit!")
            } catch {
                debugPrint("🛑 Failed to assign drink to new day: \(error.localizedDescription)")
            }
        }
    }
    
    private func delete(from drinks: [DrinkRecord], at offsets: IndexSet, in dayLog: DayLog) {
        if let index = offsets.first {
            let drinkRecord = drinks[index]
            dayLog.removeDrink(drinkRecord)
            modelContext.delete(drinkRecord)
            
            Task {
                do {
                    try await healthStoreManager.deleteAlcoholicBeverage(for: drinkRecord.timestamp)
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
