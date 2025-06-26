//
//  HistoryNavigationCard.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI

struct HistoryNavigationCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text("View Drink History")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .cardStyle()
        .accessibilityLabel("View Drink History")
        .accessibilityHint("Navigate to detailed drink history and charts")
    }
}

#Preview {
    HistoryNavigationCard {
        print("Navigate to history")
    }
    .padding()
}