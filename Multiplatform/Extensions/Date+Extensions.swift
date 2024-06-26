//
//  Date+Extensions.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/20/24.
//

import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var tomorrow: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(
            for: calendar.date(
                byAdding: .day,
                value: 1,
                to: Date()
            )!
        )
    }
    
    static var startOfWeek: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: Date()
            )
        )!
    }
    
    static var endOfWeek: Date {
        return Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: startOfWeek
        )!
    }
}
