//
//  UITestingHelpers.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 2/4/26.
//

import Foundation
import HealthKit

/// Helpers for detecting and handling UI testing mode
enum UITestingHelpers {
    /// Returns true if the app is running in UI testing mode
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    /// Returns true if HealthKit should be mocked
    static var shouldMockHealthKit: Bool {
        ProcessInfo.processInfo.environment["HEALTHKIT_MOCKED"] == "1"
    }
}

// MARK: - HealthKit Mocking Protocol

/// Protocol for mocking HealthKit operations during UI tests
protocol HealthKitMocking {
    var isMocked: Bool { get }
    func mockSave() async throws
    func mockDelete() async throws
    func mockFetch() async throws -> [Any]
}

// MARK: - Mock HealthStore Manager

/// Mock implementation of HealthStoreManager for UI testing
/// This can be used to replace the real HealthStoreManager when running UI tests
final class MockHealthStoreManager: HealthStoreManaging {
    static let shared = MockHealthStoreManager()

    private init() {}

    func save(_ sample: HKQuantitySample) async throws {
        // Mock implementation - does nothing
        print("[Mock HealthKit] Saved sample")
    }

    // Add other mocked methods as needed
}
