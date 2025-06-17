//
//  QuickActionHandler.swift
//  DrinkTracker
//
//  Created by Mike Baldwin on 6/3/25.
//

import UIKit
import SwiftUI

@MainActor
@Observable
class QuickActionHandler {
    var activeAction: QuickActionType?
    
    static let shared = QuickActionHandler()
    
    private init() {}
    
    func handle(_ action: QuickActionType) {
        print("🎯 QuickActionHandler.handle called with: \(action)")
        activeAction = action
        print("🎯 QuickActionHandler.activeAction set to: \(String(describing: activeAction))")
    }
    
    func clearAction() {
        activeAction = nil
    }
}
