//
//  QuickActionType.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/12/25.
//

enum QuickActionType: String, CaseIterable {
    case drinkCalculator = "com.mikebaldwin.DrinkTracker.drinkCalculator"
    case customDrink = "com.mikebaldwin.DrinkTracker.customDrink"
    case quickEntry = "com.mikebaldwin.DrinkTracker.quickEntry"
    
    var title: String {
        switch self {
        case .drinkCalculator: return "Drink Calculator"
        case .customDrink: return "Add Custom Drink"
        case .quickEntry: return "Quick Entry"
        }
    }
}
