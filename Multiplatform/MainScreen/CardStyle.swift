//
//  CardStyle.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI

extension Color {
    #if os(iOS)
    static let dashboardBackground = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    static let primaryAction = Color(UIColor.systemBlue)
    static let successGreen = Color(UIColor.systemGreen)
    static let warningOrange = Color(UIColor.systemOrange)
    static let dangerRed = Color(UIColor.systemRed)
    static let subtleGray = Color(UIColor.secondaryLabel)
    #elseif os(watchOS)
    static let dashboardBackground = Color.black
    static let cardBackground = Color.gray.opacity(0.2)
    static let primaryAction = Color.blue
    static let successGreen = Color.green
    static let warningOrange = Color.orange
    static let dangerRed = Color.red
    static let subtleGray = Color.gray
    #endif
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}