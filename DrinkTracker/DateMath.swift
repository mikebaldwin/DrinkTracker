//
//  DateMath.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/3/24.
//

import Foundation

struct DateMath {
    static var startOfWeek: Date {
        return Calendar.current.dateComponents(
            [
                .calendar,
                .yearForWeekOfYear,
                .weekOfYear
            ],
            from: Date()
        ).date!
    }
    
    static var endOfWeek: Date {
        return Calendar.current.date(
            byAdding: .day,
            value: 7,
            to: startOfWeek
        )!
    }
}
