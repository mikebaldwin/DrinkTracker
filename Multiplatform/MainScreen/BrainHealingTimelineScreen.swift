//
//  BrainHealingTimelineScreen.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/28/25.
//

import SwiftUI

struct BrainHealingTimelineScreen: View {
    @Environment(\.dismiss) private var dismiss
    let currentHealingDays: Double
    
    private var currentStage: BrainHealingStage {
        BrainHealingStage.stage(for: currentHealingDays)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Current Progress Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Current Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("\(Int(currentHealingDays)) days")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(currentStage.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Current Stage")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.quaternary)
                    .cornerRadius(12)
                    
                    // Timeline
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Brain Healing Timeline")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(BrainHealingStage.stages.enumerated()), id: \.element.title) { index, stage in
                            TimelineStageView(
                                stage: stage,
                                currentDays: currentHealingDays,
                                isCurrentStage: stage.title == currentStage.title
                            )
                        }
                    }
                    
                    // Information Footer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Brain Healing")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Brain healing is a gradual process that varies for each individual. The timeline shown represents general patterns observed in research, but your personal journey may differ. Each alcohol-free day contributes to your brain's recovery and long-term health.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(.quaternary)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Brain Healing")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Close brain healing timeline")
                    .accessibilityHint("Returns to the main screen")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Brain healing timeline modal")
    }
}

struct TimelineStageView: View {
    let stage: BrainHealingStage
    let currentDays: Double
    let isCurrentStage: Bool
    
    private var dayRange: String {
        if let maxDays = stage.maxDays {
            return "\(stage.minDays)-\(maxDays) days"
        } else {
            return "\(stage.minDays)+ days"
        }
    }
    
    private var isPast: Bool {
        currentDays > Double(stage.maxDays ?? Int.max)
    }
    
    private var isFuture: Bool {
        currentDays < Double(stage.minDays)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(circleColor)
                    .frame(width: 12, height: 12)
                
                if stage.title != "Long-term Recovery" {
                    Rectangle()
                        .fill(lineColor)
                        .frame(width: 2, height: 40)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(stage.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isCurrentStage ? .blue : .primary)
                    
                    Spacer()
                    
                    Text(dayRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary)
                        .cornerRadius(6)
                }
                
                if isCurrentStage {
                    Text("You are here")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                // Show first fact for current stage, or summary for others
                if isCurrentStage && !stage.facts.isEmpty {
                    Text(stage.facts[0])
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                } else if !isCurrentStage {
                    Text(stage.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .opacity(isFuture ? 0.6 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stage.title), \(dayRange)")
        .accessibilityValue(isCurrentStage ? "Current stage" : (isPast ? "Completed" : "Future stage"))
    }
    
    private var circleColor: Color {
        if isCurrentStage {
            return .blue
        } else if isPast {
            return .green
        } else {
            return .gray.opacity(0.4)
        }
    }
    
    private var lineColor: Color {
        if isPast || isCurrentStage {
            return .blue.opacity(0.3)
        } else {
            return .gray.opacity(0.2)
        }
    }
}

#Preview {
    BrainHealingTimelineScreen(currentHealingDays: 45)
}
