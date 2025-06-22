import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    // Core app functionality
    static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
    static let dataSync = Logger(subsystem: subsystem, category: "datasync")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    static let navigation = Logger(subsystem: subsystem, category: "navigation")
    static let quickActions = Logger(subsystem: subsystem, category: "quickactions")
    static let calculations = Logger(subsystem: subsystem, category: "calculations")
    
    // Platform-specific
    static let watchApp = Logger(subsystem: subsystem, category: "watch")
    static let iOSApp = Logger(subsystem: subsystem, category: "ios")
}