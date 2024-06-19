//
//  VolumeMeasurement.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/19/24.
//

import Foundation

enum VolumeMeasurement {
    case metric
    case imperial
    
    var title: String {
        switch self {
        case .metric: return "mililiters"
        case .imperial: return "ounces"
        }
    }
}
