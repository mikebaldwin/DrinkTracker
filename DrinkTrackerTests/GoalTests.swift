//
//  GoalTests.swift
//  DrinkTrackerTests
//
//  Created by Mike Baldwin on 10/15/25.
//

@testable import DrinkTracker
import Testing
import SwiftData
import Foundation

@Suite("Goal Tests")
class GoalTests {

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

    // MARK: - Goal Enum Tests

    @Test("Goal enum has correct raw values") func goalEnumRawValues() {
        #expect(Goal.moderation.rawValue == "Moderation")
        #expect(Goal.abstinence.rawValue == "Abstinence")
    }

    @Test("Goal enum can be created from raw value") func goalEnumFromRawValue() {
        let moderation = Goal(rawValue: "Moderation")
        #expect(moderation == .moderation)

        let abstinence = Goal(rawValue: "Abstinence")
        #expect(abstinence == .abstinence)
    }

    // MARK: - UserSettings Default Tests

    @Test("New UserSettings defaults to abstinence goal") func newUserSettingsDefaultGoal() throws {
        let settings = UserSettings()
        #expect(settings.goal == .abstinence)
    }

    // MARK: - SettingsStore Tests

    @Test("SettingsStore goal getter returns correct value") func settingsStoreGoalGetter() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        #expect(settingsStore.goal == .abstinence)
    }

    @Test("SettingsStore goal setter updates value") func settingsStoreGoalSetter() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.goal = .moderation
        #expect(settingsStore.goal == .moderation)

        settingsStore.goal = .abstinence
        #expect(settingsStore.goal == .abstinence)
    }

    @Test("SettingsStore goal persists across store instances") func settingsStoreGoalPersistence() throws {
        let container = try createTestContainer()
        let context1 = ModelContext(container)
        let settingsStore1 = SettingsStore(modelContext: context1)

        settingsStore1.goal = .moderation

        let context2 = ModelContext(container)
        let settingsStore2 = SettingsStore(modelContext: context2)

        #expect(settingsStore2.goal == .moderation)
    }

    // MARK: - SwiftData Migration Tests

    @Test("Goal property is persisted to SwiftData") func goalPropertyPersistedToSwiftData() throws {
        let context = try createTestContext()
        let settings = UserSettings()
        settings.goal = .moderation

        context.insert(settings)
        try context.save()

        let descriptor = FetchDescriptor<UserSettings>()
        let fetchedSettings = try context.fetch(descriptor)

        #expect(fetchedSettings.count == 1)
        guard let firstSetting = fetchedSettings.first else {
            #expect(Bool(false), "Expected UserSettings to exist")
            return
        }
        #expect(firstSetting.goal == .moderation)
    }
}
