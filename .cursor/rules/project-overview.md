---
description: DrinkTracker iOS/watchOS app project overview and architecture
alwaysApply: true
---

DrinkTracker is a modern iOS/watchOS app for tracking alcohol consumption with HealthKit integration and CloudKit sync. Built with SwiftUI, SwiftData, and modern Swift concurrency patterns.

## Target Structure
- **Multiplatform/**: Shared iOS/iPad code and business logic
- **Watch/**: watchOS-specific UI implementations  
- **Sources/DrinkTrackerData/**: Shared data layer

## Data Layer Architecture
- **SwiftData models** with `@Model` decoration for local persistence
- **CloudKit integration** using private database `iCloud.com.mikebaldwin.DrinkTracker`
- **HealthKit bidirectional sync** for iOS Health app integration

## Key Utilities
- `DrinkCalculator`: Converts ingredients to standard drinks, handles metric/imperial units and ABV/proof
- `HealthStoreManager`: Thread-safe actor for HealthKit operations
- `DataSynchronizer`: Thread-safe actor reconciling HealthKit ↔ SwiftData
- `StreakCalculator`: Calculates alcohol-free day streaks

## Concurrency Model
Uses actors extensively for thread safety:
- `actor DataSynchronizer`
- `actor HealthStoreManager` 
- Async/await throughout data operations

## Data Models
Core models: `DrinkRecord`, `CustomDrink`, `Ingredient` (Multiplatform/Models/)
Support models: `AlcoholStrength`, `VolumeMeasurement`, `UserSettings`

## Platform-Specific Features

### iOS/iPad (Multiplatform/)
- Uses `NavigationStack` for navigation
- Comprehensive calculator UI with ingredient mixing
- Chart visualization for consumption patterns
- Settings with measurement unit preferences

### watchOS (Watch/)
- Simplified UI optimized for small screen
- Quick entry functionality
- History view with essential information
- Synchronized data with iOS app