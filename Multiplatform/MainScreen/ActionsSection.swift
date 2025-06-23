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
                        .accessibilityHidden(true)
                    Text("Drink Calculator")
                }
            }
            .accessibilityLabel("Drink Calculator")
            .accessibilityHint("Opens calculator to determine alcohol content of mixed drinks")
            Button {
                onCustomDrinkTap()
            } label: {
                HStack {
                    Image(systemName: "wineglass")
                        .accessibilityHidden(true)
                    Text("Custom Drinks")
                }
            }
            .accessibilityLabel("Custom Drinks")
            .accessibilityHint("Choose from saved drink recipes")
            Button {
                onQuickEntryTap()
            } label: {
                HStack {
                    Image(systemName: "bolt")
                        .accessibilityHidden(true)
                    Text("Quick Entry")
                }
            }
            .accessibilityLabel("Quick Entry")
            .accessibilityHint("Quickly record drinks with simple plus and minus controls")
        }
    }
}