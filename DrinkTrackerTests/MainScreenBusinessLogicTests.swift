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
class MainScreenBusinessLogicTests {
    
    // MARK: - Test Setup
    
    private func createTestContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: DrinkRecord.self, CustomDrink.self, UserSettings.self,
            configurations: config
        )
    }
    
    func createTestContext() throws -> ModelContext {
        let container = try createTestContainer()
        return ModelContext(container)
    }
    
    // MARK: - Setup and Configuration Tests
    
//    @Test("Create sets model context") func createWithModelContext() {
//        let testContext = createTestContext()
//        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
//
//        // Test passes if no exception is thrown
//        #expect(true)
//    }
    
    @Test("Initial state has correct defaults") func initialStateDefaults() throws {
        let testContext = try createTestContext()
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        
        #expect(businessLogic.recordingDrinkComplete == false)
        #expect(businessLogic.currentStreak == 0)
    }
    
    // MARK: - Helper Methods
    
    func createTestSettingsStore() throws -> SettingsStore {
        let context = try createTestContext()
        return SettingsStore(modelContext: context)
    }
    
    // MARK: - Record Drink Tests
    
    @Test("Record drink toggles recording complete") func recordDrinkTogglesComplete() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
            healthStoreManager: mockHealthStore
        )
        let drink = DrinkRecord(standardDrinks: 1.5)
        
        await businessLogic.recordDrink(drink)
        
        #expect(businessLogic.recordingDrinkComplete == true)
    }
    
    @Test("Record drink creates HealthKit sample") func recordDrinkCreatesHealthKitSample() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
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
    
    @Test("Record drink sets ID from HealthKit UUID") func recordDrinkSetsHealthKitID() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
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
    
    @Test("Record drink handles HealthKit error gracefully") func recordDrinkHandlesHealthKitError() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        mockHealthStore.shouldThrow = true
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
            healthStoreManager: mockHealthStore
        )
        let drink = DrinkRecord(standardDrinks: 1.0)
        
        await businessLogic.recordDrink(drink)
        
        // Should still toggle recording complete even if HealthKit fails
        #expect(businessLogic.recordingDrinkComplete == true)
        #expect(mockHealthStore.savedSamples.isEmpty)
    }
    
    // MARK: - Streak Calculation Tests
    
    @Test("Refresh current streak with empty drinks array") func refreshCurrentStreakWithEmptyArray() throws {
        let testContext = try createTestContext()
        let settingsStore = try createTestSettingsStore()
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        let emptyDrinks: [DrinkRecord] = []
        
        let currentStreak = businessLogic.refreshCurrentStreak(from: emptyDrinks, settingsStore: settingsStore)
        
        #expect(currentStreak == 0)
        #expect(businessLogic.currentStreak == 0)
    }
    
    @Test("Refresh current streak calculates correctly") func refreshCurrentStreakCalculatesCorrectly() throws {
        let testContext = try createTestContext()
        let settingsStore = try createTestSettingsStore()
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let drink = DrinkRecord(standardDrinks: 1.0, date: fiveDaysAgo)
        
        let currentStreak = businessLogic.refreshCurrentStreak(from: [drink], settingsStore: settingsStore)
        
        #expect(currentStreak == 4)
        #expect(businessLogic.currentStreak == 4)
    }
    
    @Test("Refresh current streak updates longest when current exceeds") func refreshCurrentStreakUpdatesLongest() throws {
        let testContext = try createTestContext()
        let settingsStore = try createTestSettingsStore()
        settingsStore.longestStreak = 3
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let drink = DrinkRecord(standardDrinks: 1.0, date: fiveDaysAgo)
        
        let currentStreak = businessLogic.refreshCurrentStreak(from: [drink], settingsStore: settingsStore)
        
        #expect(currentStreak == 4)
        #expect(businessLogic.currentStreak == 4)
        #expect(settingsStore.longestStreak == 4)
    }
    
    @Test("Refresh current streak preserves longest when current is less") func refreshCurrentStreakPreservesLongest() throws {
        let testContext = try createTestContext()
        let settingsStore = try createTestSettingsStore()
        settingsStore.longestStreak = 10
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let drink = DrinkRecord(standardDrinks: 1.0, date: twoDaysAgo)
        
        let currentStreak = businessLogic.refreshCurrentStreak(from: [drink], settingsStore: settingsStore)
        
        #expect(currentStreak == 1)
        #expect(businessLogic.currentStreak == 1)
        #expect(settingsStore.longestStreak == 10)
    }
    
    @Test("Refresh current streak handles zero streak edge case") func refreshCurrentStreakHandlesZeroStreakEdgeCase() throws {
        let testContext = try createTestContext()
        let settingsStore = try createTestSettingsStore()
        settingsStore.longestStreak = 1
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        let today = Date()
        let drink = DrinkRecord(standardDrinks: 1.0, date: today)
        
        let currentStreak = businessLogic.refreshCurrentStreak(from: [drink], settingsStore: settingsStore)
        
        #expect(currentStreak == 0)
        #expect(businessLogic.currentStreak == 0)
        #expect(settingsStore.longestStreak == 0)
    }
    
    // MARK: - Custom Drink Tests
    
    @Test("Add custom drink inserts to model context") func addCustomDrinkInsertsToContext() throws {
        let testContext = try createTestContext()
        let businessLogic = MainScreenBusinessLogic.create(context: testContext)
        
        let customDrink = CustomDrink(name: "Test Drink", standardDrinks: 2.5)
        
        businessLogic.addCustomDrink(customDrink)
        
        // Verify the drink was inserted by checking the context
        let descriptor = FetchDescriptor<CustomDrink>()
        let drinks = try testContext.fetch(descriptor)
        #expect(drinks.count == 1)
        guard let firstDrink = drinks.first else {
            #expect(Bool(false), "Expected custom drink to exist")
            return
        }
        #expect(firstDrink.name == "Test Drink")
        #expect(firstDrink.standardDrinks == 2.5)
    }
    
    // MARK: - Feedback Reset Tests
    
    @Test("Reset drink recording feedback sets to false") func resetDrinkRecordingFeedbackSetsToFalse() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
            healthStoreManager: mockHealthStore
        )
        // First set it to true
        let drink = DrinkRecord(standardDrinks: 1.0)
        await businessLogic.recordDrink(drink)
        #expect(businessLogic.recordingDrinkComplete == true)
        
        businessLogic.resetDrinkRecordingFeedback()
        
        #expect(businessLogic.recordingDrinkComplete == false)
    }
    
    // MARK: - Integration Tests
    
    @Test("Record drink workflow end to end") func recordDrinkWorkflowEndToEnd() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        let mockUserDefaults = MockUserDefaults()
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
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
    
    @Test("Concurrent drink recording handles multiple calls") func concurrentDrinkRecordingHandlesMultipleCalls() async throws {
        let testContext = try createTestContext()
        let mockHealthStore = MockHealthStoreManager()
        let businessLogic = MainScreenBusinessLogic.create(
            context: testContext,
            healthStoreManager: mockHealthStore
        )
        let drink1 = DrinkRecord(standardDrinks: 1.0)
        let drink2 = DrinkRecord(standardDrinks: 2.0)
        
        async let result1: () = businessLogic.recordDrink(drink1)
        async let result2: () = businessLogic.recordDrink(drink2)
        
        await result1
        await result2
        
        #expect(mockHealthStore.savedSamples.count == 2)
    }
}
