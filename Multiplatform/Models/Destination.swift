//
//  Destination.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/12/25.
//

import Foundation

enum Destination: Hashable {
    case drinksHistory
    case calculator
    case customDrink
    case settings
    case drinkDetail(DrinkRecord)
}

enum SheetDestination: Identifiable {
    case quickEntry
    case calculator(createCustomDrink: (CustomDrink) -> Void, createDrinkRecord: (DrinkRecord) -> Void)
    case customDrink(completion: (CustomDrink) -> Void)
    case settings
    case conflictResolution(conflicts: [SyncConflict], onComplete: (Bool) -> Void)
    
    var id: String {
        switch self {
        case .quickEntry: return "quickEntry"
        case .calculator: return "calculator"
        case .customDrink: return "customDrink"
        case .settings: return "settings"
        case .conflictResolution: return "conflictResolution"
        }
    }
}

enum FullScreenDestination: Hashable, Identifiable {
    case none
    
    var id: String {
        switch self {
        case .none:
            return "none"
        }
    }
}
