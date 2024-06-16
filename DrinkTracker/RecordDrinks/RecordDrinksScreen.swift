//
//  RecordDrinksScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/16/24.
//

import SwiftUI

private enum Segment {
    case quickEntry, calculator
}

struct RecordDrinksScreen: View {
    @State private var segment = Segment.quickEntry
    
    var body: some View {
        VStack {
            Picker("Record a drink", selection: $segment) {
                Text("Quick Entry")
                Text("Calculator")
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    RecordDrinksScreen()
}
