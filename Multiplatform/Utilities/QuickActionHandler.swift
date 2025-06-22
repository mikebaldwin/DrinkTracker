//
//  QuickActionHandler.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/3/25.
//

import UIKit
import SwiftUI
import OSLog

@MainActor
@Observable
class QuickActionHandler {
    var activeAction: QuickActionType?
    
    static let shared = QuickActionHandler()
    
    private init() {}
    
    func handle(_ action: QuickActionType) {
        Logger.quickActions.info("QuickActionHandler.handle called with: \(action.rawValue, privacy: .public)")
        activeAction = action
        Logger.quickActions.debug("QuickActionHandler.activeAction set successfully")
    }
    
    func clearAction() {
        activeAction = nil
    }
}
