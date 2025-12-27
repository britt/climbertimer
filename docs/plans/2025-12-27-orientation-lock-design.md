# Fix: Landscape View for Detail View is Messed Up

**Issue**: GitHub #4 - Landscape view broken, need per-view orientation control
**Branch**: `fix/orientation-lock`
**Date**: 2025-12-27

## Requirements

- **ActiveTimerView**: All 4 orientations (portrait, portrait upside down, landscape left, landscape right)
- **All other views**: Portrait only

## Solution

Use an AppDelegate with an orientation manager to control allowed orientations per-view.

## Implementation

### New: `Shared/Services/OrientationManager.swift`

```swift
@Observable
class OrientationManager {
    var allowedOrientations: UIInterfaceOrientationMask = .portrait

    func allowAllOrientations() {
        allowedOrientations = .all
    }

    func lockToPortrait() {
        allowedOrientations = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
}
```

### New: `ClimberTimer iOS/App/AppDelegate.swift`

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationManager = OrientationManager()

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return Self.orientationManager.allowedOrientations
    }
}
```

### Modify: `ClimberTimerApp.swift`

Add `@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate`

### Modify: `ActiveTimerView.swift`

Add orientation control:
- `.onAppear { AppDelegate.orientationManager.allowAllOrientations() }`
- `.onDisappear { AppDelegate.orientationManager.lockToPortrait() }`

### Keep: `Info.plist`

Keep all 4 orientations - AppDelegate controls which are allowed at runtime.
