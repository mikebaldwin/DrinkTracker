//
//  DrinkingStatus.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import Foundation

enum DrinkingStatus: String, CaseIterable {
    case nonDrinker = "Non-drinker"
    case lightDrinker = "Light drinker" 
    case moderateDrinker = "Moderate drinker"
    case heavyDrinker = "Heavy drinker"
    
    var description: String {
        switch self {
        case .nonDrinker: return "0 drinks per week"
        case .lightDrinker: return "1-7 drinks per week"
        case .moderateDrinker: return "8-14 drinks per week" 
        case .heavyDrinker: return "15+ drinks per week"
        }
    }
}