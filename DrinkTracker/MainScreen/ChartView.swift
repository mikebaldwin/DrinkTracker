//
//  ChartView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import Charts
import SwiftUI

struct ChartView: View {
    @Environment(DrinkTrackerModel.self) private var model
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "wineglass.fill")
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Text("Today: " + Formatter.formatDecimal(model.totalStandardDrinksToday))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)

                Spacer()
                
                Text("This week: " + Formatter.formatDecimal(model.totalStandardDrinksThisWeek))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
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
                    let totalDrinks = model.dayLogs.first(where: {
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
}

//#Preview {
//    ChartView()
//}
