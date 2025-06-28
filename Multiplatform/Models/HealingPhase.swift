//
//  HealingPhase.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/28/25.
//

import Foundation

enum HealingPhase: String, Codable, CaseIterable {
    case criticalRecovery = "Critical Recovery"
    case sensitiveRecovery = "Sensitive Recovery" 
    case establishedSobriety = "Established Sobriety"
    case compromised = "Compromised"
    
    var description: String {
        switch self {
        case .criticalRecovery:
            return "Early recovery - any drinking resets progress"
        case .sensitiveRecovery:
            return "Building resilience - moderate drinking resets progress"
        case .establishedSobriety:
            return "Established sobriety - pattern-based healing"
        case .compromised:
            return "Regular drinking pattern - healing paused/regressing"
        }
    }
}