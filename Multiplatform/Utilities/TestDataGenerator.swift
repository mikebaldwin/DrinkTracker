//
//  TestDataGenerator.swift
//  DrinkTracker
//
//  Created by Claude on 6/26/25.
//

import Foundation
import SwiftData
import HealthKit
import OSLog

enum TestDataDrinkingProfile: String, CaseIterable {
    case light = "Light Drinker"
    case moderate = "Moderate Drinker"
    case heavy = "Heavy Drinker"
    case nonDrinker = "Non-drinker"
    
    var description: String {
        switch self {
        case .light: return "1-3 drinks/week"
        case .moderate: return "4-14 drinks/week"
        case .heavy: return "15+ drinks/week"
        case .nonDrinker: return "Alcohol-free lifestyle"
        }
    }
}

actor TestDataGenerator {
    private let modelContext: ModelContext
    private let healthStoreManager: HealthStoreManaging
    private let settingsStore: SettingsStore
    
    init(modelContext: ModelContext, 
         healthStoreManager: HealthStoreManaging = HealthStoreManager.shared,
         settingsStore: SettingsStore) {
        self.modelContext = modelContext
        self.healthStoreManager = healthStoreManager
        self.settingsStore = settingsStore
    }
    
    func generateTestData(profile: TestDataDrinkingProfile, 
                         monthsBack: Int = 18,
                         progressCallback: @MainActor @escaping (Double) -> Void) async throws {
        
        Logger.developer.info("Starting test data generation for profile: \(profile.rawValue)")
        
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .month, value: -monthsBack, to: endDate) else {
            throw TestDataGeneratorError.invalidDateRange
        }
        
        // Update drinking status tracking start date to match the generated data period
        settingsStore.drinkingStatusStartDate = startDate
        
        var generatedRecords: [DrinkRecord] = []
        let calendar = Calendar.current
        var currentDate = startDate
        var processedMonths = 0
        
        while currentDate < endDate {
            guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: currentDate) else {
                break
            }
            
            let actualMonthEnd = min(monthEnd, endDate)
            let monthRecords = generateDrinksForMonth(
                profile: profile,
                startDate: currentDate,
                endDate: actualMonthEnd
            )
            
            generatedRecords.append(contentsOf: monthRecords)
            currentDate = monthEnd
            processedMonths += 1
            
            let progress = Double(processedMonths) / Double(monthsBack)
            await progressCallback(progress)
        }
        
        Logger.developer.info("Generated \(generatedRecords.count) drink records")
        
        try await saveRecords(generatedRecords)
        
        Logger.developer.info("Successfully saved test data to SwiftData and HealthKit")
    }
    
    private func generateDrinksForMonth(profile: TestDataDrinkingProfile, startDate: Date, endDate: Date) -> [DrinkRecord] {
        var records: [DrinkRecord] = []
        let calendar = Calendar.current
        var currentDate = startDate
        
        while currentDate < endDate {
            guard let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) else {
                break
            }
            
            let actualWeekEnd = min(weekEnd, endDate)
            let weekRecords = generateDrinksForWeek(
                profile: profile,
                weekStart: currentDate,
                weekEnd: actualWeekEnd
            )
            
            records.append(contentsOf: weekRecords)
            currentDate = weekEnd
        }
        
        return records
    }
    
    private func generateDrinksForWeek(profile: TestDataDrinkingProfile, weekStart: Date, weekEnd: Date) -> [DrinkRecord] {
        let weeklyTarget = getWeeklyDrinkTarget(profile: profile)
        let seasonalMultiplier = getSeasonalMultiplier(for: weekStart)
        let adjustedTarget = weeklyTarget * seasonalMultiplier
        
        let randomRange = profile == .heavy ? (0.85...1.15) : (0.75...1.25)
        let targetDrinks = Double.random(in: adjustedTarget * randomRange.lowerBound...adjustedTarget * randomRange.upperBound)
        
        if profile == .nonDrinker {
            let shouldHaveDrink = Double.random(in: 0...1) < 0.02
            if shouldHaveDrink {
                let randomDay = getRandomDateInWeek(weekStart: weekStart, weekEnd: weekEnd)
                let record = DrinkRecord(standardDrinks: 1.0, date: randomDay)
                return [record]
            }
            return []
        }
        
        let drinkingDays = getDrinkingDaysForWeek(profile: profile, targetDrinks: targetDrinks)
        var records: [DrinkRecord] = []
        var remainingDrinks = targetDrinks
        
        for dayOffset in drinkingDays {
            guard let drinkingDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: weekStart),
                  drinkingDate < weekEnd else { continue }
            
            let drinksForDay = min(remainingDrinks, getDrinksPerSession(profile: profile))
            if drinksForDay > 0.1 {
                let timestamp = addRealisticTime(to: drinkingDate)
                let record = DrinkRecord(standardDrinks: drinksForDay, date: timestamp)
                records.append(record)
                remainingDrinks -= drinksForDay
            }
            
            if remainingDrinks <= 0.1 {
                break
            }
        }
        
        // Distribute remaining drinks across all days, respecting daily limits
        if remainingDrinks > 0.1 {
            remainingDrinks = distributeRemainingDrinks(remainingDrinks, across: &records, profile: profile, weekStart: weekStart, weekEnd: weekEnd)
        }
        
        return records
    }
    
    private func getWeeklyDrinkTarget(profile: TestDataDrinkingProfile) -> Double {
        switch profile {
        case .light:
            return Double.random(in: 1.0...3.0)
        case .moderate:
            return Double.random(in: 4.0...14.0)
        case .heavy:
            return Double.random(in: 20.0...30.0)
        case .nonDrinker:
            return 0.0
        }
    }
    
    private func getSeasonalMultiplier(for date: Date) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        switch month {
        case 12:
            return 1.3
        case 1:
            return 0.8
        case 6, 7, 8:
            return 1.15
        default:
            return 1.0
        }
    }
    
    private func getDrinkingDaysForWeek(profile: TestDataDrinkingProfile, targetDrinks: Double) -> [Int] {
        let maxDays: Int
        let preferredDays: [Int]
        
        switch profile {
        case .light:
            maxDays = 2
            preferredDays = [5, 6]
        case .moderate:
            maxDays = 4
            preferredDays = [0, 1, 2, 3, 4, 5, 6]
        case .heavy:
            maxDays = 5
            preferredDays = [0, 1, 2, 3, 4, 5, 6]
        case .nonDrinker:
            return []
        }
        
        let daysNeeded = min(maxDays, max(1, Int(ceil(targetDrinks / 3.0))))
        return Array(preferredDays.shuffled().prefix(daysNeeded))
    }
    
    private func getDrinksPerSession(profile: TestDataDrinkingProfile) -> Double {
        switch profile {
        case .light:
            return Double.random(in: 0.5...2.0)
        case .moderate:
            return Double.random(in: 1.0...3.0)
        case .heavy:
            return Double.random(in: 2.0...5.0)
        case .nonDrinker:
            return 1.0
        }
    }
    
    private func getMaxDrinksPerDay(profile: TestDataDrinkingProfile) -> Double {
        switch profile {
        case .light:
            return 3.0
        case .moderate:
            return 5.0
        case .heavy:
            return 8.0
        case .nonDrinker:
            return 1.0
        }
    }
    
    private func distributeRemainingDrinks(_ remainingDrinks: Double, across records: inout [DrinkRecord], profile: TestDataDrinkingProfile, weekStart: Date, weekEnd: Date) -> Double {
        let maxDrinksPerDay = getMaxDrinksPerDay(profile: profile)
        var stillRemaining = remainingDrinks
        
        // First, try to add to existing records without exceeding daily limits
        for i in 0..<records.count {
            if stillRemaining <= 0.1 { break }
            
            let canAdd = maxDrinksPerDay - records[i].standardDrinks
            if canAdd > 0.1 {
                let toAdd = min(stillRemaining, canAdd)
                records[i].standardDrinks += toAdd
                stillRemaining -= toAdd
            }
        }
        
        // If still have remaining drinks, add new drinking days
        while stillRemaining > 0.1 {
            let drinksForNewDay = min(stillRemaining, getDrinksPerSession(profile: profile))
            let newDay = getUnusedDayInWeek(weekStart: weekStart, weekEnd: weekEnd, usedDays: records.map { $0.timestamp })
            
            if let newDay = newDay {
                let timestamp = addRealisticTime(to: newDay)
                let record = DrinkRecord(standardDrinks: drinksForNewDay, date: timestamp)
                records.append(record)
                stillRemaining -= drinksForNewDay
            } else {
                // If no more days available, distribute remaining among existing days as much as possible
                for i in 0..<records.count {
                    if stillRemaining <= 0.1 { break }
                    let canAdd = maxDrinksPerDay - records[i].standardDrinks
                    if canAdd > 0.1 {
                        let toAdd = min(stillRemaining, canAdd)
                        records[i].standardDrinks += toAdd
                        stillRemaining -= toAdd
                    }
                }
                break // Exit if we can't add more days
            }
        }
        
        return stillRemaining
    }
    
    private func getUnusedDayInWeek(weekStart: Date, weekEnd: Date, usedDays: [Date]) -> Date? {
        let calendar = Calendar.current
        var currentDate = weekStart
        
        while currentDate < weekEnd {
            let isUsed = usedDays.contains { usedDay in
                calendar.isDate(currentDate, inSameDayAs: usedDay)
            }
            
            if !isUsed {
                return currentDate
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }
        
        return nil
    }
    
    private func getRandomDateInWeek(weekStart: Date, weekEnd: Date) -> Date {
        let timeInterval = weekEnd.timeIntervalSince(weekStart)
        let randomInterval = Double.random(in: 0...timeInterval)
        return weekStart.addingTimeInterval(randomInterval)
    }
    
    private func addRealisticTime(to date: Date) -> Date {
        let calendar = Calendar.current
        let hour = Int.random(in: 17...23)
        let minute = Int.random(in: 0...59)
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        return calendar.date(from: components) ?? date
    }
    
    private func saveRecords(_ records: [DrinkRecord]) async throws {
        for record in records {
            modelContext.insert(record)
            
            let quantity = HKQuantity(unit: .count(), doubleValue: record.standardDrinks)
            let sample = HKQuantitySample(
                type: HKQuantityType(.numberOfAlcoholicBeverages),
                quantity: quantity,
                start: record.timestamp,
                end: record.timestamp
            )
            
            do {
                try await healthStoreManager.save(sample)
                record.id = sample.uuid.uuidString
            } catch {
                Logger.healthKit.warning("Failed to save record to HealthKit: \(error.localizedDescription)")
            }
        }
        
        try modelContext.save()
    }
}

enum TestDataGeneratorError: Error, LocalizedError {
    case invalidDateRange
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            return "Invalid date range for test data generation"
        case .saveFailed(let error):
            return "Failed to save test data: \(error.localizedDescription)"
        }
    }
}
