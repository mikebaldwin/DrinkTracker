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
    var abv: String

    var isEmpty: Bool {
        if let volume = Double(volume), let abv = Double(abv) {
            return volume <= 0 && abv <= 0
        }
        return true
    }
    
    var isValid: Bool {
        if let volume = Double(volume), let abv = Double(abv) {
            return volume > 0 && abv > 0
        }
        return false
    }
    
    var hasOnlyABV: Bool {
        // TODO: unit test this
        if volume.isEmpty, let _ = Double(abv) {
            return true
        }
        return false
    }
}
