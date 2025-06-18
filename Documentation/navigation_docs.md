# DrinkTracker Navigation Pattern - Quick Reference Guide

## 🧠 **ADHD-Friendly Quick Start** 
*Coming back after weeks/months? Start here:*

1. **All navigation goes through `AppRouter`** - it's your single source of truth
2. **Three types of navigation**: Stack (drill-down), Sheets (modals), Full-screen (unused)
3. **To add new navigation**: Update `Destination.swift` → Add case to router → Wire up in view
4. **Main pattern**: Views trigger router methods → Router updates `@Observable` state → SwiftUI reacts

---

## 📍 **Navigation Types at a Glance**

| Type | When to Use | Current Examples | State Property |
|------|-------------|------------------|----------------|
| **Stack** | Drill-down, back button | History → Detail | `navigationPath` |
| **Sheet** | Modal, can dismiss | Quick Entry, Calculator | `presentedSheet` |
| **Full-Screen** | Immersive (unused) | None yet | `presentedFullScreen` |

---

## 🔧 **How to Add New Navigation**

### 1. Define the Destination
**File: `Destination.swift`**
```swift
// For stack navigation
enum Destination: Hashable {
    case myNewScreen
    case myScreenWithData(SomeData)
}

// For sheet navigation  
enum SheetDestination: Identifiable {
    case myNewSheet(completion: (Result) -> Void)
    
    var id: String {
        case .myNewSheet: return "myNewSheet"
    }
}
```

### 2. Add Router Method
**File: `AppRouter.swift`**
```swift
// Stack navigation
func pushMyNewScreen() {
    push(.myNewScreen)
}

// Sheet navigation
func presentMyNewSheet(completion: @escaping (Result) -> Void) {
    presentedSheet = .myNewSheet(completion: completion)
}
```

### 3. Wire Up in Views
**In your SwiftUI view:**
```swift
// Stack navigation
.navigationDestination(for: Destination.self) { destination in
    switch destination {
    case .myNewScreen:
        MyNewScreenView()
    }
}

// Sheet navigation
.sheet(item: Bindable(router).presentedSheet) { sheet in
    switch sheet {
    case .myNewSheet(let completion):
        MyNewSheetView(completion: completion)
    }
}
```

### 4. Trigger Navigation
```swift
// From any view with router access
@Environment(AppRouter.self) private var router

Button("Go to new screen") {
    router.pushMyNewScreen()
}
```

---

## 🗺️ **Current Navigation Map**

```
MainScreen (root)
├── 📱 Stack Navigation
│   ├── DrinksHistoryScreen
│   └── DrinkRecordDetailScreen
│
└── 📋 Sheet Navigation
    ├── QuickEntryView (20% height)
    ├── CalculatorScreen (full height)
    ├── CustomDrinkScreen
    └── SettingsScreen
```

---

## 🎯 **Key Router Methods You'll Use**

### Navigation Control
```swift
// Stack navigation
router.push(.someDestination)
router.pop()                    // Go back one
router.popToRoot()             // Go to main screen

// Modal navigation
router.presentSheet(.someSheet)
router.presentSettings()
router.presentCalculator(...)
router.dismiss()               // Close any modal
```

### State Checks
```swift
router.isShowingDrinksHistory  // Bool
router.canPop                  // Bool
router.navigationPath.count    // Int
```

---

## 💡 **Key Patterns & Conventions**

### ✅ **Do This**
- **Single responsibility**: Router only handles navigation, not business logic
- **Dependency injection**: Pass closures for actions (see calculator example)
- **Type safety**: Use enums for all destinations
- **Consistent naming**: `present` for modals, `push` for stack

### ❌ **Don't Do This**
- Don't put business logic in router
- Don't navigate directly from SwiftUI (always go through router)
- Don't create multiple navigation paths for same destination

### 🧩 **Special Patterns**

#### **Closures for Data Flow Back**
```swift
// When sheet needs to return data to parent
router.presentCustomDrink { customDrink in
    // This closure runs when sheet completes
    recordDrink(DrinkRecord(customDrink))
}
```

#### **Quick Actions Integration**
```swift
// Router handles system shortcuts
func handleQuickAction(_ action: QuickActionType) {
    // Always clean slate first
    popToRoot()
    dismiss()
    
    // Then navigate to shortcut destination
    switch action { ... }
}
```

---

## 🔍 **Debugging Navigation Issues**

### Common Problems & Solutions

**"Navigation not working"**
- Check: Is destination added to `.navigationDestination` switch?
- Check: Is router properly injected with `.environment(router)`?

**"Sheet not appearing"**
- Check: Is sheet case added to `.sheet` switch?
- Check: Does `SheetDestination` have correct `id` implementation?

**"Navigation state lost"**
- Check: Is router properly passed between views?
- Check: Are you using `Bindable(router)` for state binding?

**"Back button missing"**
- Stack navigation automatically adds back button
- If missing, check navigation hierarchy setup

### Debug State
```swift
// Add to any view to debug navigation state
Text("Nav count: \(router.navigationPath.count)")
Text("Has sheet: \(router.presentedSheet != nil)")
```

---

## 🚀 **Extension Examples**

### Adding a Multi-Step Flow
```swift
// 1. Add enum cases
enum Destination {
    case wizardStep1
    case wizardStep2(Step1Data)
    case wizardStep3(Step1Data, Step2Data)
}

// 2. Add navigation methods
func startWizard() { push(.wizardStep1) }
func continueWizard(with data: Step1Data) { push(.wizardStep2(data)) }

// 3. Wire up views with data passing
```

### Adding Confirmation Dialogs
```swift
// Use SwiftUI's built-in confirmation dialog
.confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
    Button("Delete", role: .destructive) {
        router.pop()
    }
}
```

---

## 📝 **Quick Checklist for New Navigation**

- [ ] Added case to appropriate `Destination` enum
- [ ] Added router method
- [ ] Added case to view's navigation switch
- [ ] Tested forward navigation
- [ ] Tested back navigation
- [ ] Tested with existing navigation states
- [ ] Added to this documentation 😉

---

*Last updated: [Current Date] - Remember to update this when you make changes!*