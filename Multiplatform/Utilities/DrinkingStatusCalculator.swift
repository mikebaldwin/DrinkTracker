//
//  DrinkingStatusCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import Foundation
import OSLog

struct DrinkingStatusCalculator {
    static func calculateStatus(
        for period: ReportingPeriod,
        drinks: [DrinkRecord], 
        userSex: Sex,
        trackingStartDate: Date
    ) -> DrinkingStatus? {
        Logger.drinkingStatus.info("🧮 Starting drinking status calculation")
        Logger.drinkingStatus.info("📊 Input: period=\(period.days) days, drinks count=\(drinks.count)")
        Logger.drinkingStatus.info("⚙️ Settings: userSex=\(userSex.rawValue), startDate=\(trackingStartDate)")
        
        let trackingStartDate = trackingStartDate
        let periodStartDate = Calendar.current.date(
            byAdding: .day, 
            value: -period.days, 
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Calendar.current.startOfDay(for: Date())
        
        Logger.drinkingStatus.info("📅 Date calculations: trackingStart=\(trackingStartDate), periodStart=\(periodStartDate)")
        
        // Use the later of tracking start date or period start date
        let effectiveStartDate = max(trackingStartDate, periodStartDate)
        Logger.drinkingStatus.info("📅 Effective start date: \(effectiveStartDate)")
        
        // If tracking period is shorter than requested period, return nil
        let daysSinceTracking = Calendar.current.dateComponents(
            [.day], 
            from: trackingStartDate, 
            to: Date()
        ).day ?? 0
        
        Logger.drinkingStatus.info("📊 Days since tracking started: \(daysSinceTracking), required: \(period.days)")
        
        guard daysSinceTracking >= period.days else { 
            Logger.drinkingStatus.info("❌ Insufficient tracking period (\(daysSinceTracking) < \(period.days)), returning nil")
            return nil 
        }
        
        let relevantDrinks = drinks.filter { drink in
            drink.timestamp >= effectiveStartDate
        }
        
        Logger.drinkingStatus.info("🍻 Relevant drinks: \(relevantDrinks.count) out of \(drinks.count) total")
        
        let totalDrinks = relevantDrinks.reduce(0) { $0 + $1.standardDrinks }
        let weeksInPeriod = Double(period.days) / 7.0
        let drinksPerWeek = totalDrinks / weeksInPeriod
        
        Logger.drinkingStatus.info("📊 Calculation: totalDrinks=\(totalDrinks), weeksInPeriod=\(weeksInPeriod), drinksPerWeek=\(drinksPerWeek)")

        // For classification alignment with display, round based on what will be shown
        // This ensures "What You See Is What You Get" - if it displays as "2 per day", it's Moderate
        let drinksPerDay = drinksPerWeek / 7.0

        // Simulate Formatter.formatDecimal rounding (1 decimal max, 0 min)
        let roundedDrinksPerDay = (drinksPerDay * 10).rounded() / 10
        let displayAlignedDrinksPerWeek = roundedDrinksPerDay * 7.0

        Logger.drinkingStatus.info("📊 Display per day: \(roundedDrinksPerDay), display-aligned per week: \(displayAlignedDrinksPerWeek)")

        let result = classifyDrinkingStatus(drinksPerWeek: displayAlignedDrinksPerWeek, sex: userSex)
//        Logger.drinkingStatus.info("✅ Final result: \(result)")
        
        return result
    }
    
    static func calculateAverageDrinksPerDay(
        for period: ReportingPeriod,
        drinks: [DrinkRecord], 
        trackingStartDate: Date
    ) -> Double? {
        let trackingStartDate = trackingStartDate
        let periodStartDate = Calendar.current.date(
            byAdding: .day, 
            value: -period.days, 
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Calendar.current.startOfDay(for: Date())
        
        let effectiveStartDate = max(trackingStartDate, periodStartDate)
        
        // Check if we have enough tracking data
        let daysSinceTracking = Calendar.current.dateComponents(
            [.day], 
            from: trackingStartDate, 
            to: Date()
        ).day ?? 0
        
        guard daysSinceTracking >= period.days else { return nil }
        
        let relevantDrinks = drinks.filter { drink in
            drink.timestamp >= effectiveStartDate
        }
        
        let totalDrinks = relevantDrinks.reduce(0) { $0 + $1.standardDrinks }
        
        // Calculate average drinks per day for the period
        return totalDrinks / Double(period.days)
    }
    
    static func calculateAverageDrinksPerWeek(
        for period: ReportingPeriod,
        drinks: [DrinkRecord], 
        trackingStartDate: Date
    ) -> Double? {
        let trackingStartDate = trackingStartDate
        let periodStartDate = Calendar.current.date(
            byAdding: .day, 
            value: -period.days, 
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Calendar.current.startOfDay(for: Date())
        
        let effectiveStartDate = max(trackingStartDate, periodStartDate)
        
        // Check if we have enough tracking data
        let daysSinceTracking = Calendar.current.dateComponents(
            [.day], 
            from: trackingStartDate, 
            to: Date()
        ).day ?? 0
        
        guard daysSinceTracking >= period.days else { return nil }
        
        let relevantDrinks = drinks.filter { drink in
            drink.timestamp >= effectiveStartDate
        }
        
        let totalDrinks = relevantDrinks.reduce(0) { $0 + $1.standardDrinks }
        let weeksInPeriod = Double(period.days) / 7.0
        
        // Calculate average drinks per week for the period
        return totalDrinks / weeksInPeriod
    }
    
    private static func classifyDrinkingStatus(drinksPerWeek: Double, sex: Sex) -> DrinkingStatus {
        Logger.drinkingStatus.info("🔍 Classifying: drinksPerWeek=\(drinksPerWeek), sex=\(sex.rawValue)")
        
        // Use explicit conditionals instead of switch to avoid floating point precision issues
        if drinksPerWeek == 0.0 {
            Logger.drinkingStatus.info("📊 Classification: 0 drinks → nonDrinker")
            return .nonDrinker
        } else if drinksPerWeek > 0.0 && drinksPerWeek <= 3.0 {
            Logger.drinkingStatus.info("📊 Classification: \(drinksPerWeek) drinks (0.0-3.0) → lightDrinker")
            return .lightDrinker
        } else if drinksPerWeek > 3.0 {
            // Apply CDC sex-specific heavy drinking thresholds
            let heavyThreshold: Double = switch sex {
            case .female: 7.0  // >7 drinks/week for females
            case .male: 14.0   // >14 drinks/week for males
            }

            Logger.drinkingStatus.info("📊 Classification: \(drinksPerWeek) drinks (3.0+), heavyThreshold=\(heavyThreshold) for \(sex.rawValue)")

            if drinksPerWeek > heavyThreshold {
                Logger.drinkingStatus.info("📊 Classification: \(drinksPerWeek) > \(heavyThreshold) → heavyDrinker")
                return .heavyDrinker
            } else {
                Logger.drinkingStatus.info("📊 Classification: \(drinksPerWeek) <= \(heavyThreshold) → moderateDrinker")
                return .moderateDrinker
            }
        } else {
            Logger.drinkingStatus.info("📊 Classification: fallback case → nonDrinker")
            return .nonDrinker
        }
    }
}
