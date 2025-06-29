//
//  BrainHealingStage.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/28/25.
//

import Foundation

struct BrainHealingStage {
    let minDays: Int
    let maxDays: Int?
    let title: String
    let facts: [String]
    let summary: String
    
    static func stage(for days: Double) -> BrainHealingStage {
        let dayCount = Int(days)
        return stages.first { stage in
            dayCount >= stage.minDays && (stage.maxDays == nil || dayCount <= stage.maxDays!)
        } ?? stages.first!
    }
    
    static let stages: [BrainHealingStage] = [
        BrainHealingStage(
            minDays: 0,
            maxDays: 7,
            title: "Initial Recovery",
            facts: [
                "Your brain is already working to rebalance important neurotransmitters that help regulate mood and sleep. This process begins within hours of your last drink.",
                "You may notice your sleep patterns starting to improve. While it might take some time to feel fully rested, your brain is learning to sleep naturally again.",
                "Any anxiety or irritability you're experiencing should begin to lessen as your nervous system adjusts to functioning without alcohol."
            ],
            summary: "Your brain begins rebalancing neurotransmitters for better mood and sleep regulation within hours."
        ),
        BrainHealingStage(
            minDays: 7,
            maxDays: 30,
            title: "Early Healing",
            facts: [
                "Your short-term memory is likely improving, making it easier to remember conversations, where you put things, and daily tasks.",
                "You may notice better coordination and balance as your cerebellum recovers. Simple activities like walking and fine motor skills are becoming more precise.",
                "Brain cells that had shrunk due to alcohol use are returning to their normal size, essentially allowing your brain to function more efficiently."
            ],
            summary: "Memory and coordination improve as brain cells return to normal size and function more efficiently."
        ),
        BrainHealingStage(
            minDays: 30,
            maxDays: 90,
            title: "Neuroplasticity Boost",
            facts: [
                "Your brain is forming new neural connections at an accelerated rate. This neuroplasticity is helping you develop healthier thinking patterns and habits.",
                "Mood stability is typically much improved by now. The emotional ups and downs that alcohol can cause are giving way to more consistent, natural feelings.",
                "You'll likely notice better concentration and higher energy levels. Mental tasks that felt difficult before may now feel more manageable."
            ],
            summary: "New neural connections form rapidly, improving mood stability, concentration, and energy levels."
        ),
        BrainHealingStage(
            minDays: 90,
            maxDays: 180,
            title: "Cognitive Recovery",
            facts: [
                "Long-term memory function continues to improve, making it easier to recall past experiences and learn new information effectively.",
                "Problem-solving abilities and critical thinking skills are enhanced as the brain regions responsible for executive function heal and strengthen.",
                "Brain imaging would show increased brain volume during this period. Your brain is literally growing healthier and more resilient."
            ],
            summary: "Long-term memory and problem-solving abilities strengthen as brain volume increases."
        ),
        BrainHealingStage(
            minDays: 180,
            maxDays: 365,
            title: "Deep Restoration", 
            facts: [
                "Emotional regulation has likely improved significantly. You're probably better at managing stress and recovering from difficult situations.",
                "Sleep quality at this stage is typically much better than before. Quality rest is now supporting all other aspects of your health and recovery.",
                "Many people find their cognitive abilities are now equal to or better than they were before alcohol became a concern. Your brain has become more efficient."
            ],
            summary: "Emotional regulation and sleep quality reach new heights as cognitive abilities become more efficient."
        ),
        BrainHealingStage(
            minDays: 365,
            maxDays: nil,
            title: "Long-term Recovery",
            facts: [
                "Your brain is now creating new brain cells through neurogenesis. This process helps maintain cognitive function and emotional resilience.",
                "Brain plasticity continues to improve, meaning your ability to learn, adapt, and form new memories keeps getting better with time.",
                "Research shows brain healing can continue for many years. Each day of sobriety is an investment in your long-term cognitive health and wellbeing."
            ],
            summary: "New brain cells form through neurogenesis while plasticity continues improving learning and adaptation."
        )
    ]
}