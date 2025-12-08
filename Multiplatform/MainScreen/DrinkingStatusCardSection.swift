//
//  DrinkingStatusCardSection.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 12/8/25.
//

import SwiftUI

struct DrinkingStatusCardSection: View {
    let drinkingStatus7Days: DrinkingStatus?
    let drinkingStatus30Days: DrinkingStatus?
    let drinkingStatusYear: DrinkingStatus?
    let average7Days: Double?
    let average30Days: Double?
    let averageYear: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                    if let average = average7Days {
                        let unit = drinkingStatus7Days == .lightDrinker ? "per week" : "per day"
                        Text("\(Formatter.formatDecimal(average)) \(unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
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
                    if let average = average30Days {
                        let unit = drinkingStatus30Days == .lightDrinker ? "per week" : "per day"
                        Text("\(Formatter.formatDecimal(average)) \(unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
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
                    if let average = averageYear {
                        let unit = drinkingStatusYear == .lightDrinker ? "per week" : "per day"
                        Text("\(Formatter.formatDecimal(average)) \(unit)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
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
        }
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
}

#Preview {
    DrinkingStatusCardSection(
        drinkingStatus7Days: .lightDrinker,
        drinkingStatus30Days: .moderateDrinker,
        drinkingStatusYear: .heavyDrinker,
        average7Days: 2.5,
        average30Days: 1.8,
        averageYear: 2.1
    )
    .padding()
}
