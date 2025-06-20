//
//  MainScreenBusinessLogicTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 6/18/25.
//

@testable import DrinkTracker
import Testing
import SwiftData
import HealthKit
import Foundation

// MARK: - Test Doubles

class MockHealthStoreManager: HealthStoreManaging {
    var shouldThrow = false
    var savedSamples: [HKQuantitySample] = []
    var throwError: Error = NSError(domain: "TestError", code: 1, userInfo: nil)
    
    func save(_ sample: HKQuantitySample) async throws {
        if shouldThrow {
            throw throwError
        }
        savedSamples.append(sample)
    }
}

class MockUserDefaults: UserDefaultsProviding {
    private var storage: [String: Int] = [:]
    
    func integer(forKey defaultName: String) -> Int {
        return storage[defaultName] ?? 0
    }
    
    func set(_ value: Int, forKey defaultName: String) {
        storage[defaultName] = value
    }
}

class MockModelContext {
    var insertedObjects: [Any] = []
}

@Suite("MainScreen Business Logic Tests")
struct MainScreenBusinessLogicTests {
    
    // MARK: - Setup and Configuration Tests
    
    @Test("Configure sets model context") func configureWithModelContext() {
        let businessLogic = MainScreenBusinessLogic()
        
        // Create an in-memory SwiftData container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: DrinkRecord.self, configurations: config)
        let context = ModelContext(container)
        
        businessLogic.configure(with: context)
        
        // Test passes if no exception is thrown
        #expect(true)
    }
    
    @Test("Initial state has correct defaults") func initialStateDefaults() {
        let businessLogic = MainScreenBusinessLogic()
        
        #expect(businessLogic.recordingDrinkComplete == false)
        #expect(businessLogic.currentStreak == 0)
    }
    
    // MARK: - Longest Streak Property Tests
    
    @Test("Longest streak reads from UserDefaults") func longestStreakReadsUserDefaults() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(5, forKey: "longestStreak")
        let businessLogic = MainScreenBusinessLogic(
            userDefaults: mockUserDefaults
        )
        
        #expect(businessLogic.longestStreak == 5)
    }
    
    @Test("Longest streak writes to UserDefaults") func longestStreakWritesUserDefaults() {
        let mockUserDefaults = MockUserDefaults()
        let businessLogic = MainScreenBusinessLogic(
            userDefaults: mockUserDefaults
        )
        
        businessLogic.longestStreak = 10
        
        #expect(mockUserDefaults.integer(forKey: "longestStreak") == 10)
    }
    
    @Test("Longest streak returns zero when not set") func longestStreakDefaultValue() {
        let mockUserDefaults = MockUserDefaults()
        let businessLogic = MainScreenBusinessLogic(
            userDefaults: mockUserDefaults
        )
        
        #expect(businessLogic.longestStreak == 0)
    }
    
    // MARK: - Record Drink Tests
    
    @Test("Record drink toggles recording complete") func recordDrinkTogglesComplete() async {
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic(
            healthStoreManager: mockHealthStore
        )
        let drink = DrinkRecord(standardDrinks: 1.5)
        
        await businessLogic.recordDrink(drink)
        
        #expect(businessLogic.recordingDrinkComplete == true)
    }
    
    @Test("Record drink creates HealthKit sample") func recordDrinkCreatesHealthKitSample() async {
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic(
            healthStoreManager: mockHealthStore
        )
        let drink = DrinkRecord(standardDrinks: 2.0)
        
        await businessLogic.recordDrink(drink)
        
        #expect(mockHealthStore.savedSamples.count == 1)
        guard let savedSample = mockHealthStore.savedSamples.first else {
            #expect(Bool(false), "Expected saved sample to exist")
            return
        }
        #expect(savedSample.quantity.doubleValue(for: .count()) == 2.0)
        #expect(savedSample.startDate == drink.timestamp)
        #expect(savedSample.endDate == drink.timestamp)
    }
    
    @Test("Record drink sets ID from HealthKit UUID") func recordDrinkSetsHealthKitID() async {
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic(
            healthStoreManager: mockHealthStore
        )
        let drink = DrinkRecord(standardDrinks: 1.0)
        let originalId = drink.id
        
        await businessLogic.recordDrink(drink)
        
        guard let savedSample = mockHealthStore.savedSamples.first else {
            #expect(Bool(false), "Expected saved sample to exist")
            return
        }
        #expect(drink.id == savedSample.uuid.uuidString)
        #expect(drink.id != originalId)
    }
    
    @Test("Record drink handles HealthKit error gracefully") func recordDrinkHandlesHealthKitError() async {
        let mockHealthStore = MockHealthStoreManager()
        mockHealthStore.shouldThrow = true
        let businessLogic = MainScreenBusinessLogic(
            healthStoreManager: mockHealthStore
        )
        let drink = DrinkRecord(standardDrinks: 1.0)
        
        await businessLogic.recordDrink(drink)
        
        // Should still toggle recording complete even if HealthKit fails
        #expect(businessLogic.recordingDrinkComplete == true)
        #expect(mockHealthStore.savedSamples.isEmpty)
    }
    
    // MARK: - Streak Calculation Tests
    
    @Test("Refresh current streak with empty drinks array") func refreshCurrentStreakWithEmptyArray() {
        let businessLogic = MainScreenBusinessLogic()
        let emptyDrinks: [DrinkRecord] = []
        
        businessLogic.refreshCurrentStreak(from: emptyDrinks)
        
        #expect(businessLogic.currentStreak == 0)
    }
    
    @Test("Refresh current streak calculates correctly") func refreshCurrentStreakCalculatesCorrectly() {
        let businessLogic = MainScreenBusinessLogic()
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let drink = DrinkRecord(standardDrinks: 1.0, date: fiveDaysAgo)
        
        businessLogic.refreshCurrentStreak(from: [drink])
        
        #expect(businessLogic.currentStreak == 4)
    }
    
    @Test("Refresh current streak updates longest when current exceeds") func refreshCurrentStreakUpdatesLongest() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(3, forKey: "longestStreak")
        let businessLogic = MainScreenBusinessLogic(
            userDefaults: mockUserDefaults
        )
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let drink = DrinkRecord(standardDrinks: 1.0, date: fiveDaysAgo)
        
        businessLogic.refreshCurrentStreak(from: [drink])
        
        #expect(businessLogic.currentStreak == 4)
        #expect(businessLogic.longestStreak == 4)
    }
    
    @Test("Refresh current streak preserves longest when current is less") func refreshCurrentStreakPreservesLongest() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(10, forKey: "longestStreak")
        let businessLogic = MainScreenBusinessLogic(
            userDefaults: mockUserDefaults
        )
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let drink = DrinkRecord(standardDrinks: 1.0, date: twoDaysAgo)
        
        businessLogic.refreshCurrentStreak(from: [drink])
        
        #expect(businessLogic.currentStreak == 1)
        #expect(businessLogic.longestStreak == 10)
    }
    
    @Test("Refresh current streak handles zero streak edge case") func refreshCurrentStreakHandlesZeroStreakEdgeCase() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(1, forKey: "longestStreak")
        let businessLogic = MainScreenBusinessLogic(
            userDefaults: mockUserDefaults
        )
        let today = Date()
        let drink = DrinkRecord(standardDrinks: 1.0, date: today)
        
        businessLogic.refreshCurrentStreak(from: [drink])
        
        #expect(businessLogic.currentStreak == 0)
        #expect(businessLogic.longestStreak == 0)
    }
    
    // MARK: - Custom Drink Tests
    
    @Test("Add custom drink inserts to model context") func addCustomDrinkInsertsToContext() {
        let businessLogic = MainScreenBusinessLogic()
        
        // Create an in-memory SwiftData container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: CustomDrink.self, configurations: config)
        let context = ModelContext(container)
        businessLogic.configure(with: context)
        
        let customDrink = CustomDrink(name: "Test Drink", standardDrinks: 2.5)
        
        businessLogic.addCustomDrink(customDrink)
        
        // Verify the drink was inserted by checking the context
        let descriptor = FetchDescriptor<CustomDrink>()
        let drinks = try! context.fetch(descriptor)
        #expect(drinks.count == 1)
        guard let firstDrink = drinks.first else {
            #expect(Bool(false), "Expected custom drink to exist")
            return
        }
        #expect(firstDrink.name == "Test Drink")
        #expect(firstDrink.standardDrinks == 2.5)
    }
    
    // MARK: - Feedback Reset Tests
    
    @Test("Reset drink recording feedback sets to false") func resetDrinkRecordingFeedbackSetsToFalse() async {
        let businessLogic = MainScreenBusinessLogic()
        // First set it to true
        let drink = DrinkRecord(standardDrinks: 1.0)
        await businessLogic.recordDrink(drink)
        #expect(businessLogic.recordingDrinkComplete == true)
        
        businessLogic.resetDrinkRecordingFeedback()
        
        #expect(businessLogic.recordingDrinkComplete == false)
    }
    
    // MARK: - Integration Tests
    
    @Test("Record drink workflow end to end") func recordDrinkWorkflowEndToEnd() async {
        let mockHealthStore = MockHealthStoreManager()
        let mockUserDefaults = MockUserDefaults()
        let businessLogic = MainScreenBusinessLogic(
            healthStoreManager: mockHealthStore,
            userDefaults: mockUserDefaults
        )
        let drink = DrinkRecord(standardDrinks: 1.5)
        
        await businessLogic.recordDrink(drink)
        
        // Verify HealthKit integration
        #expect(mockHealthStore.savedSamples.count == 1)
        guard let savedSample = mockHealthStore.savedSamples.first else {
            #expect(Bool(false), "Expected saved sample to exist")
            return
        }
        #expect(savedSample.quantity.doubleValue(for: .count()) == 1.5)
        
        // Verify state changes
        #expect(businessLogic.recordingDrinkComplete == true)
        
        // Verify ID was set
        guard let savedSample = mockHealthStore.savedSamples.first else {
            #expect(Bool(false), "Expected saved sample to exist for ID verification")
            return
        }
        #expect(drink.id == savedSample.uuid.uuidString)
    }
    
    @Test("Concurrent drink recording handles multiple calls") func concurrentDrinkRecordingHandlesMultipleCalls() async {
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic(
            healthStoreManager: mockHealthStore
        )
        let drink1 = DrinkRecord(standardDrinks: 1.0)
        let drink2 = DrinkRecord(standardDrinks: 2.0)
        
        async let result1 = businessLogic.recordDrink(drink1)
        async let result2 = businessLogic.recordDrink(drink2)
        
        await result1
        await result2
        
        #expect(mockHealthStore.savedSamples.count == 2)
    }
}
