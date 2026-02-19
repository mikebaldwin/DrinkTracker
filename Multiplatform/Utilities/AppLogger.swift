import OSLog

// NOTE: nonisolated(unsafe) is required here despite compiler warnings suggesting it's unnecessary.
// Without it, these static Logger properties are inferred as @MainActor isolated, causing
// "Main actor-isolated static property cannot be accessed from outside of the actor" errors
// throughout the codebase. The warning is a false positive and should be ignored.

extension Logger {
    private nonisolated(unsafe) static let subsystem = Bundle.main.bundleIdentifier!

    // Core app functionality
    nonisolated(unsafe) static let calculations = Logger(subsystem: subsystem, category: "calculations")
    nonisolated(unsafe) static let dataSync = Logger(subsystem: subsystem, category: "datasync")
    nonisolated(unsafe) static let developer = Logger(subsystem: subsystem, category: "developer")
    nonisolated(unsafe) static let drinkingStatus = Logger(subsystem: subsystem, category: "drinkingstatus")
    nonisolated(unsafe) static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
    nonisolated(unsafe) static let navigation = Logger(subsystem: subsystem, category: "navigation")
    nonisolated(unsafe) static let quickActions = Logger(subsystem: subsystem, category: "quickactions")
    nonisolated(unsafe) static let settings = Logger(subsystem: subsystem, category: "settings")
    nonisolated(unsafe) static let ui = Logger(subsystem: subsystem, category: "ui")

    // Platform-specific
    nonisolated(unsafe) static let watchApp = Logger(subsystem: subsystem, category: "watch")
    nonisolated(unsafe) static let iOSApp = Logger(subsystem: subsystem, category: "ios")
}
