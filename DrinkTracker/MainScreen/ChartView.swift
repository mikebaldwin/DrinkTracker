//
//  ChartView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import Charts
import SwiftUI

struct ChartView: View {
    private var dayLogs: [DayLog]
    private var totalStandardDrinksToday: Double
    private var totalStandardDrinksThisWeek: Double
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            NavigationLink {
                DayLogHistoryScreen()
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "wineglass.fill")
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    
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
                    // use the first(where:) method to find the corresponding
                    // dayLog entry for each day of the week. We compare the
                    // weekday component of the date property with the index of
                    // the current day in the daysOfWeek array (plus 1 to match
                    // the weekday numbering). If a matching entry is found, we
                    // use its totalDrinks value; otherwise, we use 0 as the
                    // default value.
                    let totalDrinks = dayLogs.first(where: {
                        Calendar.current.component(.weekday, from: $0.date) ==
                        daysOfWeek.firstIndex(of: day)! + 1
                    })?.totalDrinks ?? 0
                    
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Drinks", totalDrinks)
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: daysOfWeek) { _ in
                    AxisValueLabel()
                }
            }
            .padding()
        }
    }
    
    init(
        dayLogs: [DayLog],
        totalStandardDrinksToday: Double,
        totalStandardDrinksThisWeek: Double
    ) {
        self.dayLogs = dayLogs
        self.totalStandardDrinksToday = totalStandardDrinksToday
        self.totalStandardDrinksThisWeek = totalStandardDrinksThisWeek
    }
}

//#Preview {
//    ChartView()
//}
