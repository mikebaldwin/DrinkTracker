//
//  SceneDelegate.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/3/25.
//

import UIKit
import SwiftUI
import OSLog

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    private var pendingQuickAction: UIApplicationShortcutItem?
    
    override init() {
        super.init()
        Logger.quickActions.debug("SceneDelegate initialized")
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        Logger.quickActions.debug("SceneDelegate.scene willConnectTo called")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Check if launched from quick action
        if let shortcutItem = connectionOptions.shortcutItem {
            Logger.quickActions.info("Found Quick Action on launch: \(shortcutItem.type, privacy: .public)")
            pendingQuickAction = shortcutItem
        } else {
            Logger.quickActions.debug("No Quick Action on launch")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Logger.quickActions.debug("SceneDelegate.sceneDidBecomeActive called")
        // Handle any pending quick action
        if let pendingAction = pendingQuickAction {
            Logger.quickActions.info("Handling pending Quick Action: \(pendingAction.type, privacy: .public)")
            handleQuickAction(pendingAction)
            pendingQuickAction = nil
        } else {
            Logger.quickActions.debug("No pending Quick Action")
        }
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        Logger.quickActions.info("WindowScene performActionFor called with: \(shortcutItem.type, privacy: .public)")
        let handled = handleQuickAction(shortcutItem)
        completionHandler(handled)
    }

    private func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        Logger.quickActions.info("Quick Action received: \(shortcutItem.type, privacy: .public)")
        
        guard let actionType = QuickActionType(rawValue: shortcutItem.type) else {
            Logger.quickActions.error("Failed to parse Quick Action type: \(shortcutItem.type, privacy: .public)")
            return false
        }
        
        Logger.quickActions.info("Handling Quick Action: \(actionType.rawValue, privacy: .public)")
        QuickActionHandler.shared.handle(actionType)
        return true
    }
}
