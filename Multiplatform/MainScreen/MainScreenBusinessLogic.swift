//
//  MainScreenBusinessLogic.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 4/24/24.
//

import SwiftUI
import SwiftData
import HealthKit
import Observation

@Observable
class MainScreenBusinessLogic {
    // MARK: - State Management
    
    private(set) var recordingDrinkComplete = false
    private(set) var currentStreak = 0
    
    // MARK: - Dependencies
    
    private let healthStoreManager: HealthStoreManaging
    private let userDefaults: UserDefaultsProviding
    private var modelContext: ModelContext?
    
    // MARK: - Initializers
    
    init(
        healthStoreManager: HealthStoreManaging = HealthStoreManager.shared,
        userDefaults: UserDefaultsProviding = UserDefaults.standard
    ) {
        self.healthStoreManager = healthStoreManager
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Properties
    
    var longestStreak: Int {
        get { userDefaults.integer(forKey: "longestStreak") }
        set { userDefaults.set(newValue, forKey: "longestStreak") }
    }
    
    // MARK: - Setup
    
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Business Logic Methods
    
    func recordDrink(_ drink: DrinkRecord) async {
        do {
            let sample = HKQuantitySample(
                type: HKQuantityType(.numberOfAlcoholicBeverages),
                quantity: HKQuantity(
                    unit: HKUnit.count(),
                    doubleValue: drink.standardDrinks
                ),
                start: drink.timestamp,
                end: drink.timestamp
            )
            
            try await healthStoreManager.save(sample)
            debugPrint("✅ Drink saved to HealthKit on \(drink.timestamp)")
            
            drink.id = sample.uuid.uuidString
            
        } catch {
            debugPrint("🛑 Failed to save drink to HealthKit: \(error.localizedDescription)")
        }
        
        modelContext?.insert(drink)
        recordingDrinkComplete.toggle()
    }
    
    func addCustomDrink(_ customDrink: CustomDrink) {
        modelContext?.insert(customDrink)
        try? modelContext?.save()
    }
    
    func refreshCurrentStreak(from allDrinks: [DrinkRecord]) {
        guard let drink = allDrinks.first else { return }
        
        currentStreak = StreakCalculator().calculateCurrentStreak(drink)
        
        if currentStreak == 0 && longestStreak == 1 {
            // prevents giving streak credit user has gone zero days without alcohol
            longestStreak = 0
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    func resetDrinkRecordingFeedback() {
        recordingDrinkComplete = false
    }
}
