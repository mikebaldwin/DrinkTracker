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
    
    @State private var currentFactIndex = 0
    @State private var showFullTimeline = false
    @State private var isSliding = false
    
    private var savingsAmount: Double {
        SavingsCalculator.calculateSavings(
            currentStreak: currentStreak,
            monthlySpend: monthlyAlcoholSpend
        )
    }
    
    private var healingStage: BrainHealingStage {
        BrainHealingStage.stage(for: healingMomentumDays)
    }
    
    private var currentFact: String {
        let facts = healingStage.facts
        guard !facts.isEmpty else { return "" }
        return facts[currentFactIndex % facts.count]
    }
    
    private struct FactItem {
        let id: Int
        let fact: String
    }
    
    private var extendedFactsWithWrapAround: [FactItem] {
        let facts = healingStage.facts
        guard !facts.isEmpty else { return [] }
        
        var items: [FactItem] = []
        
        // Add last item at beginning for smooth wrap-around
        items.append(FactItem(id: -1, fact: facts.last!))
        
        // Add all regular items
        for (index, fact) in facts.enumerated() {
            items.append(FactItem(id: index, fact: fact))
        }
        
        // Add first item at end for smooth wrap-around
        items.append(FactItem(id: facts.count, fact: facts.first!))
        
        return items
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
                
                HStack {
                    Button {
                        navigateToFact(direction: .previous)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Previous healing fact")
                    .accessibilityHint("Shows the previous brain healing fact, loops to last fact when at beginning")
                    
                    // Paging fact display with swipe support and wrap-around
                    TabView(selection: $currentFactIndex) {
                        ForEach(extendedFactsWithWrapAround, id: \.id) { item in
                            Text(item.fact)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .fixedSize(horizontal: false, vertical: true)
                                .tag(item.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 60)
                    .onChange(of: currentFactIndex) { oldValue, newValue in
                        handleWrapAroundTransition(oldValue: oldValue, newValue: newValue)
                    }
                    
                    Button {
                        navigateToFact(direction: .next)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Next healing fact")
                    .accessibilityHint("Shows the next brain healing fact, loops to first fact when at end")
                }
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
        guard !facts.isEmpty else { return }
        
        currentFactIndex = Int.random(in: 0..<facts.count)
    }
    
    private enum NavigationDirection {
        case next, previous
    }
    
    private func handleWrapAroundTransition(oldValue: Int, newValue: Int) {
        let facts = healingStage.facts
        guard !facts.isEmpty else { return }
        
        // Handle wrap-around from swipe gestures
        if newValue == -1 {
            // Swiped to duplicate last item, jump to actual last item
            DispatchQueue.main.async {
                currentFactIndex = facts.count - 1
            }
        } else if newValue == facts.count {
            // Swiped to duplicate first item, jump to actual first item  
            DispatchQueue.main.async {
                currentFactIndex = 0
            }
        }
    }
    
    private func navigateToFact(direction: NavigationDirection) {
        let facts = healingStage.facts
        guard !facts.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            switch direction {
            case .next:
                currentFactIndex = (currentFactIndex + 1) % facts.count
            case .previous:
                currentFactIndex = currentFactIndex == 0 ? facts.count - 1 : currentFactIndex - 1
            }
        }
    }
}

#Preview {
    AlcoholFreeDaysCard(
        currentStreak: 6,
        longestStreak: 14,
        showSavings: true,
        monthlyAlcoholSpend: 100.0,
        healingMomentumDays: 45.0
    )
    .padding()
}