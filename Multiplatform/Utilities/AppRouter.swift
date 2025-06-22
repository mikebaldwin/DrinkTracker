import SwiftUI
import Observation

@Observable
class AppRouter {
    var navigationPath = NavigationPath()
    var presentedSheet: SheetDestination?
    var presentedFullScreen: FullScreenDestination?
    
    private var addCustomDrinkHandler: ((CustomDrink) -> Void)?
    private var recordDrinkHandler: ((DrinkRecord) -> Void)?
    
    // MARK: - Navigation Actions
    
    func setQuickActionHandlers(
        addCustomDrink: @escaping (CustomDrink) -> Void,
        recordDrink: @escaping (DrinkRecord) -> Void
    ) {
        addCustomDrinkHandler = addCustomDrink
        recordDrinkHandler = recordDrink
    }
    
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
    
    func presentCalculator(
        createCustomDrink: @escaping (CustomDrink) -> Void,
        createDrinkRecord: @escaping (DrinkRecord) -> Void
    ) {
        presentedSheet = .calculator(
            createCustomDrink: createCustomDrink,
            createDrinkRecord: createDrinkRecord
        )
    }
    
    func presentCustomDrink(completion: @escaping (CustomDrink) -> Void) {
        presentedSheet = .customDrink(completion: completion)
    }
    
    func presentSettings() {
        presentedSheet = .settings
    }
    
    func presentConflictResolution(
        conflicts: [SyncConflict],
        onComplete: @escaping (Bool) -> Void
    ) {
        presentedSheet = .conflictResolution(conflicts: conflicts, onComplete: onComplete)
    }

    func handleQuickAction(_ action: QuickActionType) {
        if navigationPath.count > 0 {
            popToRoot()
        }
        
        dismiss()
        
        switch action {
        case .drinkCalculator:
            guard let addCustomDrink = addCustomDrinkHandler,
                  let recordDrink = recordDrinkHandler else { return }
            presentCalculator(
                createCustomDrink: addCustomDrink,
                createDrinkRecord: recordDrink
            )
        case .customDrink:
            guard let recordDrink = recordDrinkHandler else { return }
            presentCustomDrink { customDrink in
                recordDrink(DrinkRecord(customDrink))
            }
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
