//
//  AlcoholStrength.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/19/24.
//

import Foundation

enum AlcoholStrength {
    case abv
    case proof
    
    var title: String {
        switch self {
        case .abv: return "ABV %"
        case .proof: return "Proof"
        }
    }
}
