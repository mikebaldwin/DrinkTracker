//
//  ChartView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import Charts
import SwiftUI

struct ChartView: View {
    @AppStorage("dailyTarget") private var dailyLimit: Double?
    @AppStorage("weeklyTarget") private var weeklyLimit: Double?
    
    private var drinkRecords: [DrinkRecord]
    private var totalStandardDrinksToday: Double
    private var totalStandardDrinksThisWeek: Double
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            NavigationLink(value: Destination.drinksHistory) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "wineglass.fill")
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                        .accessibilityHidden(true)
                    
                    Text("Today: " + Formatter.formatDecimal(totalStandardDrinksToday))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    
                    Spacer()
                    
                    Text("This week: " + Formatter.formatDecimal(totalStandardDrinksThisWeek))
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Drink summary")
            .accessibilityValue("Today: \(Formatter.formatDecimal(totalStandardDrinksToday)) drinks, This week: \(Formatter.formatDecimal(totalStandardDrinksThisWeek)) drinks")
            .accessibilityHint("Tap to view detailed drink history")
            .padding(
                EdgeInsets(
                    top: 6,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
            )
            
            Chart {
                ForEach(daysOfWeek, id: \.self) { day in
                    let totalDrinks = drinkRecords.reduce(into: 0.0) { partialResult, drinkRecord in
                        if Calendar.current.component(.weekday, from: drinkRecord.timestamp) ==
                            daysOfWeek.firstIndex(of: day)! + 1 {
                            partialResult += drinkRecord.standardDrinks
                        }
                    }
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Drinks", totalDrinks)
                    )
                    .foregroundStyle(gradientColorFor(totalDrinks: totalDrinks))
                    
                    if let dailyLimit, shouldShowRuleMark() {
                        RuleMark(y: .value("Daily Limit", dailyLimit))
                            .foregroundStyle(.red)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: daysOfWeek) { value in
                    if daysOfWeek[value.index].isToday {
                        AxisValueLabel()
                            .foregroundStyle(.blue)
                    } else {
                        AxisValueLabel()
                    }
                }
            }
            .padding()
        }
    }
    
    init(
        drinkRecords: [DrinkRecord],
        totalStandardDrinksToday: Double,
        totalStandardDrinksThisWeek: Double
    ) {
        self.drinkRecords = drinkRecords
        self.totalStandardDrinksToday = totalStandardDrinksToday
        self.totalStandardDrinksThisWeek = totalStandardDrinksThisWeek
    }
    
    private func gradientColorFor(totalDrinks: Double) -> LinearGradient {
        guard let dailyLimit else {
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .blue]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        let inGreenZone = totalDrinks < dailyLimit - 0.6
        let inYellowZone = totalDrinks > dailyLimit - 0.6 && totalDrinks < dailyLimit
        let inRedZone = totalDrinks >= dailyLimit
        
        switch totalDrinks {
        case _ where inGreenZone:
            return LinearGradient(
                gradient: Gradient(colors: [.green]),
                startPoint: .top,
                endPoint: .bottom
            )
        case _ where inYellowZone:
            return LinearGradient(
                gradient: Gradient(colors: [.yellow, .green]),
                startPoint: .top,
                endPoint: .bottom
            )
        case _ where inRedZone:
            return LinearGradient(
                gradient: Gradient(colors: [.red, .yellow, .green]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(
                gradient: Gradient(colors: [.blue]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private func shouldShowRuleMark() -> Bool {
//        guard let dailyTarget else { return false }
//        for dayLog in dayLogs where dayLog.totalDrinks > dailyTarget {
//            return true
//        }
        return false
    }
}

//#Preview {
//    ChartView(
//        drinkRecords: [DrinkRecord](),
//        totalStandardDrinksToday: 0.0,
//        totalStandardDrinksThisWeek:  0.0
//    )
//}

extension String {
    var isToday: Bool {
        // Get the current date and extract the day of the week
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE" // Format for abbreviated weekday
        let currentDay = dateFormatter.string(from: Date())
        
        // Compare the current day with the string value
        return self == currentDay
    }
}
