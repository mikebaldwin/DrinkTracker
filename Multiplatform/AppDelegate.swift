//
//  AppDelegate.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/3/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("🎯 AppDelegate didFinishLaunchingWithOptions")
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        print("🎯 AppDelegate configurationForConnecting called")
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        print("🎯 AppDelegate configured SceneDelegate")
        return configuration
    }
}
