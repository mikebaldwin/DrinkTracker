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

enum SheetDestination: Hashable, Identifiable {
    case quickEntry
    
    var id: String {
        switch self {
        case .quickEntry:
            return "quickEntry"
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
