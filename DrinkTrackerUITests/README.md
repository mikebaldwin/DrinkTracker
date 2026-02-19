# DrinkTracker UI Tests

## Setup Instructions

### 1. Add UI Test Target to Xcode

1. Open `DrinkTracker.xcodeproj` in Xcode
2. Select the project in the navigator
3. Click the "+" button at the bottom of the targets list
4. Choose "UI Testing Bundle"
5. Name it `DrinkTrackerUITests`
6. Ensure the target is associated with the DrinkTracker app

### 2. Add Test Files

The following files have been created in the `DrinkTrackerUITests` folder:
- `DrinkTrackerUITests.swift` - Main UI test cases
- `DrinkTrackerUITestsLaunchTests.swift` - Launch tests

Add these files to the UI test target in Xcode:
1. Select each file in the Project Navigator
2. In the File Inspector (right panel), check the box for `DrinkTrackerUITests` target

### 3. Add UITestingHelpers to Main Target

The `Multiplatform/Utilities/UITestingHelpers.swift` file provides helpers for detecting UI test mode:
1. Add this file to the main DrinkTracker target
2. Use `UITestingHelpers.isUITesting` to detect test mode
3. Use `UITestingHelpers.shouldMockHealthKit` to enable HealthKit mocking

### 4. Configure HealthKit Mocking

To avoid HealthKit permission dialogs during UI tests, modify `HealthStoreManager` initialization:

```swift
// In HealthStoreManager
static let shared: HealthStoreManaging = {
    if UITestingHelpers.shouldMockHealthKit {
        return MockHealthStoreManager.shared
    }
    return HealthStoreManager()
}()
```

### 5. Running Tests

#### Via Xcode:
1. Select the `DrinkTrackerUITests` scheme
2. Press `Cmd + U` to run all tests
3. Or click the diamond icon next to individual test methods

#### Via Command Line:
```bash
xcodebuild test \
  -project DrinkTracker.xcodeproj \
  -scheme "DrinkTracker Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:DrinkTrackerUITests
```

## Test Coverage

### Main Screen Tests
- ✅ Main screen appears with all buttons
- ✅ Navigate to settings
- ✅ Tap quick entry button

### Settings Tests
- ✅ Change goal setting (moderation/abstinence)
- ✅ Modify daily limit
- ✅ Delete all data flow (with cancellation)

### Planned Tests
- Record drink flow
- Edit drink
- Delete drink
- Sync with HealthKit (mocked)
- Generate test data
- Navigation between screens

## Best Practices

1. **Always mock HealthKit** - Use `HEALTHKIT_MOCKED=1` environment variable
2. **Reset app state** - Consider resetting UserDefaults/SwiftData between tests
3. **Use accessibility identifiers** - Already implemented via `AccessibilityIdentifiers`
4. **Handle animations** - Use `waitForExistence(timeout:)` for async UI
5. **Avoid flakiness** - Use explicit waits, avoid hardcoded delays
6. **Organize with XCTActivity** - Use `XCTContext.runActivity` for multi-step workflows (Xcode 16+)
7. **Annotate with @MainActor** - Required for UI test methods in Swift 6

## Troubleshooting

### Tests fail to find elements
- Verify accessibility identifiers are set in the app code
- Check that elements are actually visible (not hidden or off-screen)
- Use `app.debugDescription` to inspect the view hierarchy

### Permission dialogs appear
- Ensure `HEALTHKIT_MOCKED=1` is set in launch environment
- Verify UITestingHelpers are properly integrated

### Tests are slow
- Run on faster simulators (iPhone 15 vs older models)
- Reduce test scope to specific test cases
- Consider parallel testing in CI/CD

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
- name: Run UI Tests
  run: |
    xcodebuild test \
      -project DrinkTracker.xcodeproj \
      -scheme "DrinkTracker Dev" \
      -destination 'platform=iOS Simulator,name=iPhone 15' \
      -only-testing:DrinkTrackerUITests \
      -resultBundlePath TestResults
```
