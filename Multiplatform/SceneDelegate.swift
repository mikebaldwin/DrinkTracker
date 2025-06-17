//
//  SceneDelegate.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/3/25.
//

import UIKit
import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    private var pendingQuickAction: UIApplicationShortcutItem?
    
    override init() {
        super.init()
        print("🎯 SceneDelegate initialized")
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        print("🎯 SceneDelegate.scene willConnectTo called")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Check if launched from quick action
        if let shortcutItem = connectionOptions.shortcutItem {
            print("🎯 SceneDelegate found Quick Action on launch: \(shortcutItem.type)")
            pendingQuickAction = shortcutItem
        } else {
            print("🎯 SceneDelegate no Quick Action on launch")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("🎯 SceneDelegate.sceneDidBecomeActive called")
        // Handle any pending quick action
        if let pendingAction = pendingQuickAction {
            print("🎯 SceneDelegate handling pending Quick Action: \(pendingAction.type)")
            handleQuickAction(pendingAction)
            pendingQuickAction = nil
        } else {
            print("🎯 SceneDelegate no pending Quick Action")
        }
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        print("🎯 SceneDelegate.windowScene performActionFor called with: \(shortcutItem.type)")
        let handled = handleQuickAction(shortcutItem)
        completionHandler(handled)
    }

    private func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("🎯 Quick Action received: \(shortcutItem.type)")
        print("🎯 Quick Action title: \(shortcutItem.localizedTitle)")
        
        guard let actionType = QuickActionType(rawValue: shortcutItem.type) else {
            print("❌ Failed to parse Quick Action type: \(shortcutItem.type)")
            return false
        }
        
        print("✅ Handling Quick Action: \(actionType)")
        QuickActionHandler.shared.handle(actionType)
        return true
    }
}
