//
//  LimitsSection.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct LimitsSection: View {
    let dailyLimit: Double?
    let weeklyLimit: Double?
    let remainingDrinksToday: Double
    let totalStandardDrinksThisWeek: Double
    
    var body: some View {
        Section("Limits") {
            if dailyLimit != nil {
                HStack {
                    Text("Today")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if remainingDrinksToday > 0 {
                        let noun = remainingDrinksToday == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(remainingDrinksToday)) \(noun) below limit")
                    } else if remainingDrinksToday == 0 {
                        Text("Daily limit reached!")
                    } else {
                        let drinksOverLimit = remainingDrinksToday * -1
                        let noun = drinksOverLimit == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(drinksOverLimit)) \(noun) over limit")
                            .foregroundStyle(Color(.red))
                            .fontWeight(.semibold)
                    }
                }
            }
            if let weeklyLimit {
                HStack {
                    Text("This week")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    let remainingDrinks = weeklyLimit - totalStandardDrinksThisWeek
                    if remainingDrinks > 0 {
                        let noun = remainingDrinks == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(remainingDrinks)) \(noun) below limit")
                    } else if remainingDrinks == weeklyLimit {
                        Text("Weekly limit reached!")
                    } else {
                        let drinksOverLimit = remainingDrinks * -1
                        let noun = drinksOverLimit == 1 ? "drink" : "drinks"
                        Text("\(Formatter.formatDecimal(drinksOverLimit)) \(noun) over limit")
                            .foregroundStyle(Color(.red))
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}