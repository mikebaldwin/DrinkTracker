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

    var isEmpty: Bool { volume == "" && abv == "" }
}
