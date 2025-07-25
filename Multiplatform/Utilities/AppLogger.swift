import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    
    // Core app functionality
    static let calculations = Logger(subsystem: subsystem, category: "calculations")
    static let dataSync = Logger(subsystem: subsystem, category: "datasync")
    static let developer = Logger(subsystem: subsystem, category: "developer")
    static let drinkingStatus = Logger(subsystem: subsystem, category: "drinkingstatus")
    static let healthKit = Logger(subsystem: subsystem, category: "healthkit")
    static let navigation = Logger(subsystem: subsystem, category: "navigation")
    static let quickActions = Logger(subsystem: subsystem, category: "quickactions")
    static let settings = Logger(subsystem: subsystem, category: "settings")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    // Platform-specific
    static let watchApp = Logger(subsystem: subsystem, category: "watch")
    static let iOSApp = Logger(subsystem: subsystem, category: "ios")
}