//
//  UserDefaultsProviding.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/19/25.
//

import Foundation

protocol UserDefaultsProviding {
    func integer(forKey defaultName: String) -> Int
    func set(_ value: Int, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProviding {}
