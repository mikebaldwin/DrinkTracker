//
//  StreaksSection.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct StreaksSection: View {
    let currentStreak: Int
    let longestStreak: Int
    
    var body: some View {
        Section("Alcohol-free Days") {
            HStack {
                Text("Current streak")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(currentStreak) days")
            }
            HStack {
                Text("Longest streak")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(longestStreak) days")
            }
        }
    }
}