//
//  AlcoholFreeDaysCard.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/26/25.
//

import SwiftUI

struct AlcoholFreeDaysCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let showSavings: Bool
    let monthlyAlcoholSpend: Double
    let healingMomentumDays: Double
    let randomizationTrigger: Int
    
    @State private var currentFact = ""
    @State private var showFullTimeline = false
    
    private var savingsAmount: Double {
        SavingsCalculator.calculateSavings(
            currentStreak: currentStreak,
            monthlySpend: monthlyAlcoholSpend
        )
    }
    
    private var healingStage: BrainHealingStage {
        BrainHealingStage.stage(for: healingMomentumDays)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Original header with trophy icon
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text("Alcohol-free Days")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            // Original format with separate labeled rows
            VStack(spacing: 8) {
                HStack {
                    Text("Current streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(currentStreak) days")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Longest streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(longestStreak) days")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                if showSavings && monthlyAlcoholSpend > 0 {
                    HStack {
                        Text("Money saved")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(SavingsCalculator.formatCurrency(savingsAmount))
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Brain Healing Section (ALWAYS SHOWN)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Brain Healing")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button {
                        showFullTimeline = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("View brain healing timeline")
                    .accessibilityHint("Shows detailed brain healing timeline and stages")
                }
                
                Text(healingStage.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Single tappable fact display
                Button {
                    showFullTimeline = true
                } label: {
                    Text(currentFact)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Brain healing fact")
                .accessibilityHint("Tap to view full brain healing timeline")
                .padding(.horizontal, 8)
            }
            .padding(.top, 8)
            .onAppear {
                // Set random fact when view appears
                randomizeCurrentFact()
            }
            .onChange(of: healingStage.title) { _, _ in
                // Reset to random fact when healing stage changes
                randomizeCurrentFact()
            }
            .onChange(of: randomizationTrigger) { _, _ in
                // Randomize fact when trigger changes (e.g., app restored from background)
                randomizeCurrentFact()
            }
        }
        .cardStyle()
        .sheet(isPresented: $showFullTimeline) {
            BrainHealingTimelineScreen(currentHealingDays: healingMomentumDays)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        var label = "Alcohol-free Days. Current streak: \(currentStreak) days, Longest streak: \(longestStreak) days"
        
        if showSavings && monthlyAlcoholSpend > 0 {
            label += ", Money saved: \(SavingsCalculator.formatCurrency(savingsAmount))"
        }
        
        label += ", Brain healing: \(healingStage.title), \(currentFact)"
        
        return label
    }
    
    private func randomizeCurrentFact() {
        let facts = healingStage.facts
        guard !facts.isEmpty else { 
            currentFact = ""
            return 
        }
        
        currentFact = facts.randomElement() ?? ""
    }
}

#Preview {
    AlcoholFreeDaysCard(
        currentStreak: 6,
        longestStreak: 14,
        showSavings: true,
        monthlyAlcoholSpend: 100.0,
        healingMomentumDays: 45.0,
        randomizationTrigger: 0
    )
    .padding()
}