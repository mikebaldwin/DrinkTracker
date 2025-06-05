---
description: Xcode project management rules for DrinkTracker
globs: ["**/*.pbxproj"]
alwaysApply: false
---

## Xcode Project Management

### Adding New Files
When creating new files that need to be added to the Xcode project:
- Prompt the user to add them manually instead of modifying project.pbxproj directly
- Include the file path and target information in the prompt

### Manual project.pbxproj Editing
When manually adding entries to project.pbxproj:
- Use Xcode-format UUIDs: 24 uppercase hexadecimal characters without dashes
- Generate with: `uuidgen | tr '[:lower:]' '[:upper:]' | tr -d '-' | head -c 24`
- Example: `9CA852096AE948A6A353E97C`

## iOS Quick Actions
When implementing iOS Quick Actions (3D Touch/long-press app icon contextual menu):
- **MUST** use SceneDelegate (UIWindowSceneDelegate) connected via AppDelegate
- **DO NOT** use URLs - Quick Actions are handled via UIApplicationShortcutItem, not URL schemes
- Configure static Quick Actions in Info.plist with UIApplicationShortcutItems
- Handle Quick Actions in SceneDelegate methods: `windowScene(_:performActionFor:completionHandler:)` and `scene(_:willConnectTo:options:)`
- Use AppDelegate to configure SceneDelegate via `application(_:configurationForConnecting:options:)`
- Quick Actions provide `UIApplicationShortcutItem` objects, not URLs or deep links