//
//  DashboardCardView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI

struct DashboardCardView: View {
    let currentStreak: Int
    let drinkingStatus7Days: DrinkingStatus?
    let drinkingStatus30Days: DrinkingStatus?
    let drinkingStatusYear: DrinkingStatus?
    let weeklyProgress: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Current Streak")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
            
            Text("\(currentStreak) days")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Drinking Status")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Last 7 days:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    if let status = drinkingStatus7Days {
                        Text(status.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(colorForStatus(status))
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                }
                
                HStack {
                    Text("Last 30 days:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    if let status = drinkingStatus30Days {
                        Text(status.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(colorForStatus(status))
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                }
                
                HStack {
                    Text("Last year:")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    if let status = drinkingStatusYear {
                        Text(status.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(colorForStatus(status))
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                }
            }
            
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(Color.primaryAction)
                    .accessibilityHidden(true)
                Text("Weekly Progress")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            
            Text(weeklyProgress)
                .font(.headline)
                .foregroundStyle(progressColor())
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel())
    }
    
    private func colorForStatus(_ status: DrinkingStatus) -> Color {
        switch status {
        case .nonDrinker, .lightDrinker:
            return .successGreen
        case .moderateDrinker:
            return .warningOrange
        case .heavyDrinker:
            return .dangerRed
        }
    }
    
    private func progressColor() -> Color {
        if weeklyProgress.contains("below limit") || weeklyProgress.contains("On track") {
            return .successGreen
        } else if weeklyProgress.contains("over") || weeklyProgress.contains("exceeded") {
            return .dangerRed
        } else {
            return .warningOrange
        }
    }
    
    private func accessibilityLabel() -> String {
        var label = "Dashboard summary. Current streak: \(currentStreak) days. "
        
        label += "Drinking status: "
        if let status7 = drinkingStatus7Days {
            label += "Last 7 days \(status7.rawValue), "
        }
        if let status30 = drinkingStatus30Days {
            label += "Last 30 days \(status30.rawValue), "
        }
        if let statusYear = drinkingStatusYear {
            label += "Last year \(statusYear.rawValue). "
        }
        
        label += "Weekly progress: \(weeklyProgress)"
        
        return label
    }
}

#Preview {
    DashboardCardView(
        currentStreak: 6,
        drinkingStatus7Days: .lightDrinker,
        drinkingStatus30Days: .heavyDrinker,
        drinkingStatusYear: .heavyDrinker,
        weeklyProgress: "2 drinks below limit"
    )
    .padding()
}