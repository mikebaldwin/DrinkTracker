//
//  HealthStoreManager.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 5/9/24.
//

import Foundation
import HealthKit
import Observation

enum HealthKitError: Error {
    case quantityTypeNotAvailable
    case quantityTypeResultsNotFound
    case authorizationFailed
}

@Observable
final class HealthStoreManager {
    private(set) var healthStore = HKHealthStore()
    private var alcoholicBeverageType: HKQuantityType? {
        HKQuantityType.quantityType(forIdentifier: .numberOfAlcoholicBeverages)
    }
    
    func save(standardDrinks: Double, for date: Date) async throws {
        let alcoholConsumptionType = HKQuantityType(.numberOfAlcoholicBeverages)
        
        guard try await requestAuthorization() == true else {
            throw HealthKitError.authorizationFailed
        }
        let beverageCount = HKQuantity(unit: HKUnit.count(), doubleValue: standardDrinks)
        let beverageSample = HKQuantitySample(
            type: alcoholConsumptionType,
            quantity: beverageCount,
            start: date,
            end: date
        )
        
        do {
            try await healthStore.save(beverageSample)
            debugPrint("✅ HealhstoreManager saved beverageSample on startDate: \(beverageSample.startDate), endDate: \(beverageSample.endDate)")
        } catch {
            throw error
        }
    }
    
    func deleteAlcoholicBeverage(for date: Date) async throws {
        guard let sample = try await fetchSample(for: date) else {
            throw HealthKitError.quantityTypeResultsNotFound
        }
        
        do {
            try await healthStore.delete(sample)
        } catch {
            throw error
        }
    }
    
    func updateAlcoholicBeverageDate(forDate date: Date, newDate: Date) async throws {
        guard let alcoholicBeverageType else {
            throw HealthKitError.quantityTypeNotAvailable
        }
        
        guard let sample = try await fetchSample(for: date) else {
            throw HealthKitError.quantityTypeResultsNotFound
        }
        
        // Create a new quantity sample with the updated date
        let updatedSample = HKQuantitySample(
            type: alcoholicBeverageType,
            quantity: sample.quantity,
            start: newDate,
            end: newDate
        )
        
        // Save the updated sample to HealthKit
        try await healthStore.save(updatedSample)
        
        // Delete the original sample from HealthKit
        try await healthStore.delete(sample)
    }
    
    private func requestAuthorization() async throws -> Bool {
        guard let alcoholicBeverageType else {
            throw HealthKitError.quantityTypeNotAvailable
        }
        let success = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            healthStore.requestAuthorization(toShare: [alcoholicBeverageType], read: nil) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
        
        return success
    }
    
    private func fetchSample(for date: Date) async throws -> HKQuantitySample?  {
        guard let alcoholicBeverageType else {
            throw HealthKitError.quantityTypeNotAvailable
        }
        
        guard try await requestAuthorization() == true else {
            throw HealthKitError.authorizationFailed
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: []
        )
        
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
            return sample.startDate == date
        }
        
        return desiredSample
    }
}
