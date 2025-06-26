//
//  DrinksHistoryScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/8/24.
//

import SwiftData
import SwiftUI
import OSLog

struct DrinksHistoryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(SettingsStore.self) private var settingsStore
    @Query(sort: \DrinkRecord.timestamp, order: .reverse) var drinkRecords: [DrinkRecord]
    
    @State private var days: [Day] = []
    private var healthStoreManager = HealthStoreManager.shared
    
    private var dailyLimit: Double? {
        settingsStore.dailyLimit > 0 ? settingsStore.dailyLimit : nil
    }
    
    private var weeklyLimit: Double? {
        settingsStore.weeklyLimit > 0 ? settingsStore.weeklyLimit : nil
    }
    
    private var thisWeeksDrinks: [DrinkRecord] {
        drinkRecords.thisWeeksRecords
    }
    
    private var totalStandardDrinksToday: Double {
        drinkRecords.todaysRecords.totalStandardDrinks
    }
    
    private var totalStandardDrinksThisWeek: Double {
        drinkRecords.thisWeeksRecords.totalStandardDrinks
    }
    
    var body: some View {
        List {
            Section {
                ChartView(
                    dailyLimit: dailyLimit,
                    weeklyLimit: weeklyLimit,
                    drinkRecords: thisWeeksDrinks,
                    totalStandardDrinksToday: totalStandardDrinksToday,
                    totalStandardDrinksThisWeek: totalStandardDrinksThisWeek
                )
            }
            
            ForEach(days) { day in
                Section(formatDate(day.date)) {
                    if day.drinks.isEmpty {
                        Text("Alcohol-free")
                            .accessibilityLabel("Alcohol-free day")
                            .accessibilityHint("No drinks recorded for this day")
                    } else {
                        ForEach(day.drinks, id: \.id) { drink in
                            NavigationLink(value: Destination.drinkDetail(drink)) {
                                HStack {
                                    Text(formatTimestamp(drink.timestamp))
                                    Spacer()
                                    Text(Formatter.formatDecimal(drink.standardDrinks))
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Drink entry")
                            .accessibilityValue("\(Formatter.formatDecimal(drink.standardDrinks)) drinks at \(formatTimestamp(drink.timestamp))")
                            .accessibilityHint("Tap to edit this drink entry")
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
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Daily total")
                            .accessibilityValue("\(Formatter.formatDecimal(day.totalDrinks)) drinks for \(formatDate(day.date))")
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Day section for \(formatAccessibleDate(day.date))")
            }
        }
        .accessibilityLabel("Drink history list")
        .accessibilityHint("Shows chronological list of recorded drinks with options to edit or delete")
        .navigationTitle("Drink History")
        .onAppear {
            buildDays()
            router.setDrinkUpdateHandler { drinkRecord, newDate in
                update(drinkRecord, with: newDate)
            }
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
    
    private func formatAccessibleDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func buildDays() {
        Logger.ui.debug("Building days from \(drinkRecords.count, privacy: .public) records")
        days.removeAll()
        
        var dayDictionary = [Date: [DrinkRecord]]()
        let calendar = Calendar.current

        // Iterate through the drinkRecords and populate the dayDictionary
        for record in drinkRecords {
            let startOfDay = calendar.startOfDay(for: record.timestamp)
            Logger.ui.debug("Processing drink record with \(record.standardDrinks, privacy: .public) standard drinks")
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
        Logger.ui.debug("Built \(days.count, privacy: .public) days for display")
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
                Logger.ui.info("Date reassigned in HealthKit successfully")
            } catch {
                Logger.ui.error("Failed to assign drink to new day: \(error.localizedDescription)")
            }
        }
    }
    
    private func delete(from drinks: [DrinkRecord], at offsets: IndexSet) {
        if let index = offsets.first {
            let drinkRecord = drinks[index]
            let drinkAmount = Formatter.formatDecimal(drinkRecord.standardDrinks)
            let drinkTime = formatTimestamp(drinkRecord.timestamp)
            
            modelContext.delete(drinkRecord)
            
            // Explicitly save the deletion before updating UI
            do {
                try modelContext.save()
                Logger.ui.info("Deleted from SwiftData and saved successfully")
                buildDays()
                
                // Announce deletion for accessibility
                UIAccessibility.post(notification: .announcement, argument: "Deleted \(drinkAmount) drinks from \(drinkTime)")
                
                // Only proceed with HealthKit deletion if SwiftData deletion succeeded
                Task {
                    do {
                        try await healthStoreManager.deleteAlcoholicBeverage(withUUID: UUID(uuidString: drinkRecord.id)!)
                        Logger.ui.info("Deleted from HealthKit successfully")
                    } catch {
                        Logger.ui.error("Failed to delete from HealthKit: \(error.localizedDescription)")
                    }
                }
            } catch {
                Logger.ui.error("Failed to save SwiftData deletion: \(error.localizedDescription)")
                // TODO: Show user feedback that deletion failed
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: DrinkRecord.self,
        configurations: config
    )

    DrinksHistoryScreen()
        .modelContainer(container)
        .environment(AppRouter())
}
