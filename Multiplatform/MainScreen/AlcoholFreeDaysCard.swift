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
    let showSavings: Bool
    let monthlyAlcoholSpend: Double
    
    private var savingsAmount: Double {
        SavingsCalculator.calculateSavings(
            currentStreak: currentStreak,
            monthlySpend: monthlyAlcoholSpend
        )
    }
    
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
                
                if showSavings && monthlyAlcoholSpend > 0 {
                    HStack {
                        Text("Money saved")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(SavingsCalculator.formatCurrency(savingsAmount))
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        var label = "Alcohol-free Days. Current streak: \(currentStreak) days, Longest streak: \(longestStreak) days"
        
        if showSavings && monthlyAlcoholSpend > 0 {
            label += ", Money saved: \(SavingsCalculator.formatCurrency(savingsAmount))"
        }
        
        return label
    }
}

#Preview {
    AlcoholFreeDaysCard(
        currentStreak: 6,
        longestStreak: 14,
        showSavings: true,
        monthlyAlcoholSpend: 100.0
    )
    .padding()
}