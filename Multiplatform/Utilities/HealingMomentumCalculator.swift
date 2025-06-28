//
//  HealingMomentumCalculator.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/28/25.
//

import Foundation

enum DrinkingPattern {
    case abstinent, light, moderate, heavy
}

struct HealingMomentumCalculator {
    
    static func updateHealingMomentum(
        drinkRecords: [DrinkRecord],
        settings: UserSettings
    ) -> (newMomentumDays: Double, newPhase: HealingPhase) {
        
        // Calculate days since last drink using same logic as StreakCalculator
        let daysSinceLastDrink: Int
        let sortedDrinks = drinkRecords.sorted { $0.timestamp > $1.timestamp }
        
        if let mostRecentDrink = sortedDrinks.first {
            // Use StreakCalculator logic for consistent day counting
            let streakCalculator = StreakCalculator()
            daysSinceLastDrink = streakCalculator.calculateCurrentStreak(mostRecentDrink)
        } else {
            // No drinks recorded - use a large number to indicate long-term sobriety
            daysSinceLastDrink = 365
        }
        
        let currentPattern = getCurrentDrinkingPattern(drinkRecords: drinkRecords)
        let currentPhase = determineHealingPhase(
            daysSinceReset: daysSinceLastDrink,
            currentPattern: currentPattern,
            currentMomentum: settings.healingMomentumDays
        )
        
        // Use total calculation approach instead of incremental updates
        switch currentPhase {
        case .criticalRecovery:
            return handleCriticalRecovery(
                pattern: currentPattern,
                totalDaysSinceReset: Double(daysSinceLastDrink)
            )
            
        case .sensitiveRecovery:
            return handleSensitiveRecovery(
                pattern: currentPattern,
                totalDaysSinceReset: Double(daysSinceLastDrink)
            )
            
        case .establishedSobriety:
            return handleEstablishedSobriety(
                pattern: currentPattern,
                totalDaysSinceReset: Double(daysSinceLastDrink)
            )
            
        case .compromised:
            return handleCompromisedHealing(
                pattern: currentPattern,
                totalDaysSinceReset: Double(daysSinceLastDrink)
            )
        }
    }
    
    private static func getCurrentDrinkingPattern(drinkRecords: [DrinkRecord]) -> DrinkingPattern {
        // For brain healing, we only care about drinking pattern since the current streak started
        // If user is on a streak (no drinks since last drink), they should be considered abstinent
        
        let sortedDrinks = drinkRecords.sorted { $0.timestamp > $1.timestamp }
        guard let mostRecentDrink = sortedDrinks.first else {
            // No drinks ever recorded - clearly abstinent
            return .abstinent
        }
        
        // Check if user is currently on a streak
        let streakCalculator = StreakCalculator()
        let currentStreak = streakCalculator.calculateCurrentStreak(mostRecentDrink)
        
        if currentStreak > 0 {
            // User is on an active streak - they are abstinent during this period
            return .abstinent
        } else {
            // User is not on a streak - check recent drinking pattern in last 30 days
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            let recentDrinks = drinkRecords.filter { $0.timestamp >= thirtyDaysAgo }
            let totalDrinks = recentDrinks.reduce(0) { $0 + $1.standardDrinks }
            
            switch totalDrinks {
            case 0...3: return .abstinent
            case 4...12: return .light
            case 13...30: return .moderate
            default: return .heavy
            }
        }
    }
    
    private static func determineHealingPhase(
        daysSinceReset: Int,
        currentPattern: DrinkingPattern,
        currentMomentum: Double
    ) -> HealingPhase {
        
        // If currently in moderate/heavy drinking, phase is compromised
        if currentPattern == .moderate || currentPattern == .heavy {
            return .compromised
        }
        
        // Otherwise, determine by days since reset
        switch daysSinceReset {
        case 0...30:
            return .criticalRecovery
        case 31...90:
            return .sensitiveRecovery
        default:
            return .establishedSobriety
        }
    }
    
    private static func handleCriticalRecovery(
        pattern: DrinkingPattern,
        totalDaysSinceReset: Double
    ) -> (Double, HealingPhase) {
        
        if pattern != .abstinent {
            // Any drinking resets in critical period
            return (0.0, .criticalRecovery)
        } else {
            // Return total days since reset (like streak calculator)
            return (totalDaysSinceReset, .criticalRecovery)
        }
    }
    
    private static func handleSensitiveRecovery(
        pattern: DrinkingPattern,
        totalDaysSinceReset: Double
    ) -> (Double, HealingPhase) {
        
        switch pattern {
        case .abstinent:
            return (totalDaysSinceReset, .sensitiveRecovery)
        case .light:
            // Slower progress but no reset
            return (totalDaysSinceReset * 0.5, .sensitiveRecovery)
        case .moderate, .heavy:
            // Still resets in sensitive period
            return (0.0, .criticalRecovery)
        }
    }
    
    private static func handleEstablishedSobriety(
        pattern: DrinkingPattern,
        totalDaysSinceReset: Double
    ) -> (Double, HealingPhase) {
        
        switch pattern {
        case .abstinent:
            return (totalDaysSinceReset, .establishedSobriety)
        case .light:
            return (totalDaysSinceReset * 0.8, .establishedSobriety)
        case .moderate:
            // Healing pauses but doesn't regress - maintain current level
            return (totalDaysSinceReset * 0.6, .establishedSobriety)
        case .heavy:
            // Transition to compromised phase
            return (totalDaysSinceReset * 0.4, .compromised)
        }
    }
    
    private static func handleCompromisedHealing(
        pattern: DrinkingPattern,
        totalDaysSinceReset: Double
    ) -> (Double, HealingPhase) {
        
        if pattern == .abstinent {
            // Starting fresh recovery
            return (0.0, .criticalRecovery)
        } else {
            // Significantly reduced healing based on total days and drinking pattern
            let regressionMultiplier = pattern == .heavy ? 0.2 : 0.3
            let newMomentum = max(0, totalDaysSinceReset * regressionMultiplier)
            return (newMomentum, .compromised)
        }
    }
}