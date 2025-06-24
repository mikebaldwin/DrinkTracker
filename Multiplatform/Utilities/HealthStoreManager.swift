//
//  HealthStoreManager.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/9/24.
//

import Foundation
import HealthKit
import OSLog

// MARK: - HealthKitError
enum HealthKitError: Error {
    case quantityTypeNotAvailable
    case quantityTypeResultsNotFound
    case authorizationFailed
    case noStatisticsCollectionRetrieved
}

extension HKQuantitySample: @unchecked @retroactive Sendable { }

protocol HealthStoreManaging {
    func save(_ sample: HKQuantitySample) async throws
}

// MARK: - HealthStoreManager
extension HealthStoreManager: HealthStoreManaging {}

final actor HealthStoreManager {
    static let shared = HealthStoreManager()
    
    let healthStore = HKHealthStore()
    
    private var alcoholicBeverageType: HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)
    }
    private let healthKitQueue = DispatchQueue(label: "com.DrinkTracker.healthkit", qos: .background)
    
    private init() { }
    
    func save(_ sample: HKQuantitySample) async throws {
        try await validateAuthorizationAndType()
        
        do {
            try await self.healthStore.save(sample)
            Logger.healthKit.info("Successfully saved drink record to HealthKit")
        } catch {
            Logger.healthKit.error("Failed to save drink record: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteAlcoholicBeverage(withUUID uuid: UUID) async throws {
        guard let sample = try await fetchSample(uuid: uuid) else {
            throw HealthKitError.quantityTypeResultsNotFound
        }
        
        healthKitQueue.async {
            Task {
                do {
                    try await self.healthStore.delete(sample)
                } catch {
                    throw error
                }
            }
        }
    }
    
    func updateAlcoholicBeverageDate(_ newDate: Date, withUUID uuid: UUID) async throws {
        let alcoholicBeverageType = try getAlcoholicBeverageType()
        let sample = try await fetchSample(uuid: uuid)
        
        guard let sample else {
            throw HealthKitError.quantityTypeResultsNotFound
        }
        
        let updatedSample = HKQuantitySample(
            type: alcoholicBeverageType,
            quantity: sample.quantity,
            start: newDate,
            end: newDate
        )
        
        try await self.healthStore.save(updatedSample)
        try await self.healthStore.delete(sample)
    }
    
    @discardableResult
    func isAuthorized() async throws -> Bool {
        let alcoholicBeverageType = try getAlcoholicBeverageType()
        
        let success = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            healthStore.requestAuthorization(toShare: [alcoholicBeverageType], read: [alcoholicBeverageType]) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
        
        return success
    }
    
    private func getAlcoholicBeverageType() throws -> HKQuantityType {
        guard let alcoholicBeverageType else {
            throw HealthKitError.quantityTypeNotAvailable
        }
        return alcoholicBeverageType
    }
    
    private func validateAuthorizationAndType() async throws {
        _ = try getAlcoholicBeverageType()
        guard try await isAuthorized() else {
            throw HealthKitError.authorizationFailed
        }
    }
    
    private func fetchSample(uuid: UUID) async throws -> HKQuantitySample?  {
        let alcoholicBeverageType = try getAlcoholicBeverageType()
        try await validateAuthorizationAndType()
        
        let predicate = HKQuery.predicateForObject(with: uuid)
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: alcoholicBeverageType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { query, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let samples = samples as? [HKQuantitySample] {
                    continuation.resume(returning: samples)
                } else {
                    continuation.resume(returning: [])
                }
            }
            
            healthStore.execute(query)
        }
        
        let desiredSample = samples.first { sample in
            return sample.uuid == uuid
        }
        
        return desiredSample
    }
    
    func fetchDrinkDataForWeekOf(date: Date) async throws -> [DailyTotal] {
        let alcoholicBeverageType = try getAlcoholicBeverageType()
        try await validateAuthorizationAndType()
        
        let startOfWeek = Date.startOfWeek
        let endOfWeek = Date.endOfWeek
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfWeek,
            end: endOfWeek,
            options: []
        )
        
        let interval = DateComponents(day: 1)
        
        let statisticsCollection = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKStatisticsCollection, Error>) in
            let query = HKStatisticsCollectionQuery(
                quantityType: alcoholicBeverageType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startOfWeek,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { query, statisticsCollection, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let statisticsCollection = statisticsCollection {
                    continuation.resume(returning: statisticsCollection)
                } else {
                    continuation.resume(throwing: HealthKitError.noStatisticsCollectionRetrieved)
                }
            }
            
            healthStore.execute(query)
        }
        
        var dailyTotals: [DailyTotal] = []
        
        statisticsCollection.enumerateStatistics(from: startOfWeek, to: endOfWeek) { statistics, stop in
            if let quantity = statistics.sumQuantity() {
                let dailyTotal = DailyTotal(
                    totalDrinks: quantity.doubleValue(for: .count()),
                    date: statistics.startDate
                )
                dailyTotals.append(dailyTotal)
            }
        }
        
        return dailyTotals
    }
    
    func fetchAllDrinkSamples() async throws -> [HKQuantitySample] {
        let alcoholicBeverageType = try getAlcoholicBeverageType()
        try await validateAuthorizationAndType()
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        // Create a predicate that includes all time
        let predicate = HKQuery.predicateForSamples(
            withStart: nil,
            end: nil,
            options: []
        )

        Logger.healthKit.debug("Starting HealthKit sample fetch")

        let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: alcoholicBeverageType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { query, samples, error in
                if let error {
                    Logger.healthKit.error("Failed to fetch samples: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else if let samples = samples as? [HKQuantitySample] {
                    Logger.healthKit.info("Successfully fetched \(samples.count, privacy: .public) HealthKit samples")
                    continuation.resume(returning: samples)
                } else {
                    Logger.healthKit.info("No HealthKit samples found")
                    continuation.resume(returning: [])
                }
            }
            
            healthStore.execute(query)
        }
        
        return samples
    }
    
    func fetchAllDrinkData() async throws -> [DrinkRecord] {
        let samples = try await fetchAllDrinkSamples()
        
        let drinkRecords = samples.map { sample in
            DrinkRecord(
                standardDrinks: sample.quantity.doubleValue(for: .count()),
                date: sample.startDate
            )
        }
        
        return drinkRecords
    }

}
