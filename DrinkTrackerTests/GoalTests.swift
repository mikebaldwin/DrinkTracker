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

    // MARK: - UI Visibility Tests

    @Test("Abstinence goal should show streak UI elements") func abstinenceGoalShouldShowStreakUI() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.goal = .abstinence

        #expect(settingsStore.goal == .abstinence)
    }

    @Test("Moderation goal should hide streak UI elements") func moderationGoalShouldHideStreakUI() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.goal = .moderation

        #expect(settingsStore.goal == .moderation)
    }

    @Test("Goal switch from abstinence to moderation preserves streak data") func goalSwitchPreservesStreakData() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.goal = .abstinence
        settingsStore.longestStreak = 30

        settingsStore.goal = .moderation

        #expect(settingsStore.goal == .moderation)
        #expect(settingsStore.longestStreak == 30)
    }

    @Test("Goal switch from moderation to abstinence preserves streak data") func goalSwitchFromModerationPreservesStreakData() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.goal = .moderation
        settingsStore.longestStreak = 15

        settingsStore.goal = .abstinence

        #expect(settingsStore.goal == .abstinence)
        #expect(settingsStore.longestStreak == 15)
    }

    @Test("Streak calculation continues regardless of goal setting") func streakCalculationContinuesRegardlessOfGoal() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.goal = .moderation
        let initialLongestStreak = settingsStore.longestStreak

        settingsStore.longestStreak = 25

        #expect(settingsStore.longestStreak == 25)
        #expect(settingsStore.goal == .moderation)
    }

    @Test("Multiple rapid goal changes handle state correctly") func multipleRapidGoalChangesHandleStateCorrectly() throws {
        let context = try createTestContext()
        let settingsStore = SettingsStore(modelContext: context)

        settingsStore.longestStreak = 20

        settingsStore.goal = .moderation
        settingsStore.goal = .abstinence
        settingsStore.goal = .moderation

        #expect(settingsStore.goal == .moderation)
        #expect(settingsStore.longestStreak == 20)
    }

    @Test("Goal preference syncs correctly across SettingsStore instances") func goalPreferenceSyncsAcrossInstances() throws {
        let container = try createTestContainer()
        let context1 = ModelContext(container)
        let settingsStore1 = SettingsStore(modelContext: context1)

        settingsStore1.goal = .moderation

        let context2 = ModelContext(container)
        let settingsStore2 = SettingsStore(modelContext: context2)

        #expect(settingsStore2.goal == .moderation)
    }
}
