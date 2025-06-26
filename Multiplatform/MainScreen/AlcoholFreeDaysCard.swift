//
//  AlcoholFreeDaysCard.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI

struct AlcoholFreeDaysCard: View {
    let currentStreak: Int
    let longestStreak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text("Alcohol-free Days")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Current streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(currentStreak) days")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Longest streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(longestStreak) days")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Alcohol-free Days")
        .accessibilityValue("Current streak: \(currentStreak) days, Longest streak: \(longestStreak) days")
    }
}

#Preview {
    AlcoholFreeDaysCard(
        currentStreak: 6,
        longestStreak: 14
    )
    .padding()
}