---
description: Swift code style and syntax rules for DrinkTracker
globs: ["**/*.swift"]
alwaysApply: false
---

Follow Google's Swift Style Guide: https://google.github.io/swift/

## Indentation
Use 4 spaces for indentation (not 2 spaces or tabs)

## Swift-Specific Syntax Rules

### Optional Binding
When unwrapping optionals with matching variable names, use the shorthand syntax:
```swift
// Correct
if let settings {
    // use settings
}

// Incorrect
if let settings = settings {
    // use settings
}
```
This applies to all optional binding contexts: if-let, guard-let, while-let, etc.

### Observable Pattern
- Prefer `@Observable` over `@ObservableObject` for observable classes
- Use `@Environment` instead of `@EnvironmentObject` with `@Observable` classes
- Use `@State` instead of `@StateObject` with `@Observable` classes

## Naming Conventions

### Type Names
Avoid generic suffixes like "Manager", "Helper", "Utility" in type names. Use specific, descriptive names that clearly communicate the type's responsibility.

Examples:
- `QuickActionProvider` (creates quick actions)
- `DataSynchronizer` (syncs data) 
- `StreakCalculator` (calculates streaks)

### SwiftUI View Names
- Append "Screen" for views that represent entire screens of the app
  - Examples: `MainScreen`, `SettingsScreen`
- Append "View" for views that are components or subviews
  - Examples: `ChartView`, `QuickEntryView`