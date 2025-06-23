## Development Workflow
- When you create a new file, stop and prompt me to add it to the xcode project

## Testing
- When running unit tests, use the following command: xcodebuild test -project DrinkTracker.xcodeproj -scheme DrinkTracker -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:DrinkTrackerTests ENABLE_SWIFT_TESTING=YES

## Data Architecture
- The app should never have more than one model context for data persistance