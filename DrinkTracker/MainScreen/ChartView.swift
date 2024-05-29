//
//  ChartView.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/29/24.
//

import Charts
import SwiftUI

struct ChartView: View {
    @AppStorage("dailyTarget") private var dailyTarget: Double?
    @AppStorage("weeklyTarget") private var weeklyTarget: Double?
    
    @Environment(HealthStoreManager.self) private var healthStoreManager

    @State private var dailyTotals = [DailyTotal]()
    
    private var totalStandardDrinksToday: Double {
        guard let today = dailyTotals.first(where: { Calendar.current.isDateInToday($0.date) }) else {
            return 0.0
        }
        return today.totalDrinks
    }
    private var totalStandardDrinksThisWeek: Double {
        dailyTotals.reduce(into: 0) { partialResult, dailyTotal in
            partialResult += dailyTotal.totalDrinks
        }
    }
    
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
                    let totalDrinks = dailyTotals.first(where: {
                        Calendar.current.component(.weekday, from: $0.date) ==
                        daysOfWeek.firstIndex(of: day)! + 1
                    })?.totalDrinks ?? 0
                    
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Drinks", totalDrinks)
                    )
                    .foregroundStyle(gradientColorFor(totalDrinks: totalDrinks))

                    if let dailyTarget, shouldShowRuleMark() {
                        RuleMark(y: .value("Daily Target", dailyTarget))
                            .foregroundStyle(.red)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: daysOfWeek) { _ in
                    AxisValueLabel()
                }
            }
            .padding()
        }
        .onAppear {
            refresh()
        }
    }
    
    private func gradientColorFor(totalDrinks: Double) -> LinearGradient {
        guard let dailyTarget else {
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .blue]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        let inGreenZone = totalDrinks < dailyTarget - 0.6
        let inYellowZone = totalDrinks > dailyTarget - 0.6 && totalDrinks < dailyTarget
        let inRedZone = totalDrinks >= dailyTarget
        
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
    
    func refresh() {
        Task {
            do {
                dailyTotals = try await healthStoreManager.fetchDrinkDataForWeekOf(date: Date())
            } catch {
                debugPrint("🛑 Failed to get dailyTotals: \(error.localizedDescription)")
            }
        }
    }
    
    private func shouldShowRuleMark() -> Bool {
        guard let dailyTarget else { return false }
        for total in dailyTotals where total.totalDrinks > dailyTarget {
            return true
        }
        return false
    }
}

//#Preview {
//    ChartView()
//}
 
