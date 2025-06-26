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
        VStack(spacing: 12) {
            Button {
                onQuickEntryTap()
            } label: {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundStyle(Color.primaryAction)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick Entry")
                            .font(.headline)
                            .foregroundStyle(Color.primaryAction)
                        Text("Record standard drinks")
                            .font(.subheadline)
                            .foregroundStyle(Color.subtleGray)
                    }
                    
                    Spacer()
                }
                .frame(height: 80)
                .padding(16)
                .background(Color.primaryAction.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primaryAction, lineWidth: 1)
                )
                .cornerRadius(12)
            }
            .accessibilityLabel("Quick Entry")
            .accessibilityHint("Quickly record drinks with simple plus and minus controls")
            
            HStack(spacing: 12) {
                Button {
                    onCalculatorTap()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.primaryAction)
                            .accessibilityHidden(true)
                        
                        VStack(spacing: 2) {
                            Text("Calculator")
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                            Text("Mix drinks")
                                .font(.caption)
                                .foregroundStyle(Color.subtleGray)
                        }
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                }
                .cardStyle()
                .accessibilityLabel("Drink Calculator")
                .accessibilityHint("Opens calculator to determine alcohol content of mixed drinks")
                
                Button {
                    onCustomDrinkTap()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "wineglass")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.primaryAction)
                            .accessibilityHidden(true)
                        
                        VStack(spacing: 2) {
                            Text("Custom Drinks")
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                            Text("Saved recipes")
                                .font(.caption)
                                .foregroundStyle(Color.subtleGray)
                        }
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                }
                .cardStyle()
                .accessibilityLabel("Custom Drinks")
                .accessibilityHint("Choose from saved drink recipes")
            }
        }
    }
}