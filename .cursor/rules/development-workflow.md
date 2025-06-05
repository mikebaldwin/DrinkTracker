---
description: Development workflow and testing guidelines for DrinkTracker
alwaysApply: true
---

## Development Commands

### Building and Testing
```bash
# Build the project
xcodebuild -project DrinkTracker.xcodeproj -scheme DrinkTracker build

# Run unit tests
xcodebuild test -project DrinkTracker.xcodeproj -scheme DrinkTracker -destination 'platform=iOS Simulator,name=iPhone 15'

# Open in Xcode
open DrinkTracker.xcodeproj
```

### Testing Framework
Uses modern Swift Testing with `@Test` and `@Suite` annotations instead of XCTest. Test files use the `.swift` extension and are located in `DrinkTrackerTests/` and `DrinkTrackerWatch Watch AppTests/`.

## Development Guidelines

### When modifying calculations
Test changes in `DrinkCalculatorTests.swift` - comprehensive test coverage for alcohol content calculations including edge cases and unit conversions.

### When working with data sync
Both `HealthStoreManager` and `DataSynchronizer` are actors - use `await` when calling their methods and ensure proper error handling for HealthKit authorization.

### When adding new models
Follow SwiftData patterns with `@Model` decoration and ensure CloudKit compatibility for cross-device sync.

### Git Workflow
- Commit changes frequently as you work, aiming for the smallest commit that represents a single logical unit of work
- Always ensure the app builds successfully and unit tests pass before committing
- Each commit should be both necessary and sufficient to complete one specific task or fix