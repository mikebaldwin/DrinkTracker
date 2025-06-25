//
//  ReportingPeriod.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/25/25.
//

import Foundation

enum ReportingPeriod: String, CaseIterable {
    case week7 = "Last 7 days"
    case days30 = "Last 30 days"  
    case year = "Last year"
    
    var days: Int {
        switch self {
        case .week7: return 7
        case .days30: return 30
        case .year: return 365
        }
    }
}