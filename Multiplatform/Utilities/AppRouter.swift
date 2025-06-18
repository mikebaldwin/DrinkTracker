import SwiftUI
import Observation

@Observable
class AppRouter {
    var navigationPath = NavigationPath()
    var presentedSheet: SheetDestination?
    var presentedFullScreen: FullScreenDestination?
    
    // MARK: - Navigation Actions
    
    func push(_ destination: Destination) {
        navigationPath.append(destination)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }
    
    func presentFullScreen(_ screen: FullScreenDestination) {
        presentedFullScreen = screen
    }
    
    func dismiss() {
        presentedSheet = nil
        presentedFullScreen = nil
    }
    
    // MARK: - Quick Action Support
    
    var shouldShowCalculatorSheet = false
    var shouldShowCustomDrinkSheet = false
    var shouldShowSettingsSheet = false
    
    func handleQuickAction(_ action: QuickActionType) {
        // Pop to root if we're showing drink history
        if navigationPath.count > 0 {
            popToRoot()
        }
        
        // Dismiss any presented sheets
        dismiss()
        shouldShowCalculatorSheet = false
        shouldShowCustomDrinkSheet = false
        shouldShowSettingsSheet = false
        
        // Present the appropriate screen based on action
        switch action {
        case .drinkCalculator:
            shouldShowCalculatorSheet = true
        case .customDrink:
            shouldShowCustomDrinkSheet = true
        case .quickEntry:
            presentSheet(.quickEntry)
        }
    }
    
    // MARK: - Drink Detail Support
    
    var didFinishUpdatingDrinkRecord: ((DrinkRecord, Date) -> Void)?
    
    func setDrinkUpdateHandler(_ handler: @escaping (DrinkRecord, Date) -> Void) {
        didFinishUpdatingDrinkRecord = handler
    }
    
    // MARK: - Convenience Methods
    
    var isShowingDrinksHistory: Bool {
        navigationPath.count > 0
    }
    
    var canPop: Bool {
        !navigationPath.isEmpty
    }
}