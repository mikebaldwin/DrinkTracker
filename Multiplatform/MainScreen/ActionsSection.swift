//
//  ActionsSection.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI

struct ActionsSection: View {
    let onCalculatorTap: () -> Void
    let onCustomDrinkTap: () -> Void
    let onQuickEntryTap: () -> Void
    
    var body: some View {
        Section {
            Button {
                onCalculatorTap()
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Drink Calculator")
                }
            }
            Button {
                onCustomDrinkTap()
            } label: {
                HStack {
                    Image(systemName: "wineglass")
                    Text("Custom Drinks")
                }
            }
            Button {
                onQuickEntryTap()
            } label: {
                HStack {
                    Image(systemName: "bolt")
                    Text("Quick Entry")
                }
            }
        }
    }
}