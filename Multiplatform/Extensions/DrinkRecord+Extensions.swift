//
//  DrinkRecord+Extensions.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import Foundation

extension Array where Element == DrinkRecord {
    var thisWeeksRecords: [DrinkRecord] {
        filter { $0.timestamp >= Date.startOfWeek }
    }
    
    var todaysRecords: [DrinkRecord] {
        filter { $0.timestamp < Date.tomorrow && $0.timestamp >= Date.startOfToday }
    }
    
    var totalStandardDrinks: Double {
        reduce(into: 0.0) { $0 += $1.standardDrinks }
    }
}