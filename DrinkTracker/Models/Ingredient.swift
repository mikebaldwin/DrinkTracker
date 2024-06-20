//
//  DrinkComponent.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/6/24.
//

import Foundation

struct Ingredient: Identifiable {
    let id = UUID()
    var volume: String
    var strength: String
    var isMetric = false

    var isEmpty: Bool {
        if let volume = Double(volume), let abv = Double(strength) {
            return volume <= 0 && abv <= 0
        }
        return true
    }
    
    var isValid: Bool {
        if let volume = Double(volume), let abv = Double(strength) {
            return volume > 0 && abv > 0
        }
        return false
    }
    
    var hasOnlyABV: Bool {
        if volume.isEmpty || volume == "0", let _ = Double(strength) {
            return true
        }
        return false
    }
}
