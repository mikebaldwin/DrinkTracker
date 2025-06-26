//
//  LimitsCard.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI

struct LimitsCard: View {
    let dailyLimit: Double?
    let weeklyLimit: Double?
    let remainingDrinksToday: Double
    let totalStandardDrinksThisWeek: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text("Limits")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 8) {
                if let dailyLimit = dailyLimit {
                    HStack {
                        Text("Today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(dailyLimitText)
                            .font(.headline)
                            .foregroundColor(dailyLimitColor)
                    }
                }
                
                if let weeklyLimit = weeklyLimit {
                    HStack {
                        Text("This week")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(weeklyLimitText)
                            .font(.headline)
                            .foregroundColor(weeklyLimitColor)
                    }
                }
            }
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Limits")
        .accessibilityValue(accessibilityValue)
    }
    
    private var dailyLimitText: String {
        if remainingDrinksToday > 0 {
            let noun = remainingDrinksToday == 1 ? "drink" : "drinks"
            return "\(Formatter.formatDecimal(remainingDrinksToday)) \(noun) below limit"
        } else if remainingDrinksToday == 0 {
            return "Daily limit reached!"
        } else {
            let drinksOverLimit = remainingDrinksToday * -1
            let noun = drinksOverLimit == 1 ? "drink" : "drinks"
            return "\(Formatter.formatDecimal(drinksOverLimit)) \(noun) over limit"
        }
    }
    
    private var dailyLimitColor: Color {
        remainingDrinksToday >= 0 ? .primary : .red
    }
    
    private var weeklyLimitText: String {
        guard let weeklyLimit = weeklyLimit else { return "" }
        let remainingDrinks = weeklyLimit - totalStandardDrinksThisWeek
        
        if remainingDrinks > 0 {
            let noun = remainingDrinks == 1 ? "drink" : "drinks"
            return "\(Formatter.formatDecimal(remainingDrinks)) \(noun) below limit"
        } else if remainingDrinks == 0 {
            return "Weekly limit reached!"
        } else {
            let drinksOverLimit = remainingDrinks * -1
            let noun = drinksOverLimit == 1 ? "drink" : "drinks"
            return "\(Formatter.formatDecimal(drinksOverLimit)) \(noun) over limit"
        }
    }
    
    private var weeklyLimitColor: Color {
        guard let weeklyLimit = weeklyLimit else { return .primary }
        let remainingDrinks = weeklyLimit - totalStandardDrinksThisWeek
        return remainingDrinks >= 0 ? .primary : .red
    }
    
    private var accessibilityValue: String {
        var value = ""
        if dailyLimit != nil {
            value += "Today: \(dailyLimitText)"
        }
        if weeklyLimit != nil {
            if !value.isEmpty { value += ", " }
            value += "This week: \(weeklyLimitText)"
        }
        return value
    }
}

#Preview {
    LimitsCard(
        dailyLimit: 2.0,
        weeklyLimit: 14.0,
        remainingDrinksToday: 1.5,
        totalStandardDrinksThisWeek: 8.0
    )
    .padding()
}