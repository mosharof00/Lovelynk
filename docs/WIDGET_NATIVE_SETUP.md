# iOS Home & Lock Screen Widgets — Setup Guide

Production widget architecture for **Lovelynk**.

## Naming (production)

| Item | Value |
|------|--------|
| App Group | `group.com.lovelynk.app` |
| Widget source folder | `ios/LovelynkWidgets/` |
| Xcode extension target | `LovelynkWidgetsExtension` |
| Extension bundle id | `com.lovelynk.app.LovelynkWidgets` |

## Architecture

```
Flutter App                          Widget Extension (SwiftUI)
───────────                          ──────────────────────────
WidgetDataService (demo → Supabase)  reads data keys
WidgetStyleStore (Customise)    →    App Group (UserDefaults)
WidgetSyncService                    reads style keys
  └─ syncOnAppLaunch()               WidgetKit draws tiles
  └─ applyPushPayload() [later]
```

**Dart:** `lib/app/core/widgets/`

**iOS:** `ios/LovelynkWidgets/`

## Native widgets implemented

| Widget | iOS kind | Status |
|--------|----------|--------|
| Days Together | `DaysTogetherWidget` | ✅ |
| Initials | `InitialsWidget` | ✅ |
| Others | — | Flutter in-app only (coming next) |

---

## Your Xcode checklist (first-time setup)

### 1. Apple Developer portal (one-time)

1. Go to [developer.apple.com](https://developer.apple.com) → Certificates, Identifiers & Profiles → **Identifiers**.
2. Open **App Groups** (or create one).
3. Register: **`group.com.lovelynk.app`**  
   (If you still have `group.com.lovelynk.app.widgetdemo`, you can delete it later — not needed anymore.)
4. Ensure your **App ID** for `com.lovelynk.app` has App Groups capability enabled and includes `group.com.lovelynk.app`.

### 2. Xcode — Runner app

1. Open **`ios/Runner.xcworkspace`**
2. Select **Runner** target → **Signing & Capabilities**
3. **App Groups** → remove old `widgetdemo` group if present
4. Add **`group.com.lovelynk.app`** and check it ✅

### 3. Xcode — Widget extension

1. Select **LovelynkWidgetsExtension** target (was LoveWidgetExtension)
2. **Signing & Capabilities** → same App Group: **`group.com.lovelynk.app`** ✅
3. **General** → Minimum Deployments: **iOS 16.0**
4. Confirm **LovelynkWidgets** folder in Project Navigator contains Swift files

### 4. Clean build

1. **Product → Clean Build Folder** (⇧⌘K)
2. Terminal:
   ```bash
   cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
   flutter clean && flutter pub get
   flutter run
   ```

### 5. Add widgets on Simulator

1. Run app once (syncs demo data: **76 days**, initials **J ♥ M**)
2. Home Screen → long-press → **+**
3. Search **Days Together** or **Initials** → Add
4. **Customise** tab → change colour → **Save** → widget updates

### 6. Lock screen

Long-press lock screen → Customize → add **Days Together** or **Initials**

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Widget shows 0 / empty | Force-quit app and reopen |
| Build error duplicate `@main` | Only `LovelynkWidgetBundle.swift` has `@main` |
| App Group signing error | Match group id in portal + both targets |
| Old widget still on home screen | Remove old widget, add new from gallery |

---

## Adding the next widget

1. Dart: keys in `widget_app_group.dart` + `WidgetSyncService._writeDataFor`
2. Dart: `WidgetKind.implementedKinds`
3. iOS: `Widgets/YourWidget.swift`
4. iOS: register in `LovelynkWidgetBundle.swift`
