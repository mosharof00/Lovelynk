# iOS Home & Lock Screen Widgets — Setup Guide

Production widget architecture for **Lovelynk**.

## Naming (production)

| Item | Value |
|------|--------|
| App Group | `group.com.lovelynk.ios` |
| Widget source folder | `ios/LovelynkWidgets/` |
| Xcode extension target | `LovelynkWidgetsExtension` |
| Extension bundle id | `com.lovelynk.ios.LovelynkWidgets` |

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
| Partner Distance | `PartnerDistanceWidget` | ✅ |
| Anniversary | `AnniversaryWidget` | ✅ |
| Partner Time | `PartnerTimeWidget` | ✅ (live, updates every minute) |
| Together Counter | `TogetherCounterWidget` | ✅ (live, updates every second) |
| Next Visit Countdown | `NextVisitCountdownWidget` | ✅ (live, updates every second) |
| Partner Weather | `PartnerWeatherWidget` | ✅ |
| Love Compass | `LoveCompassWidget` | ✅ |
| Heartbeat | `HeartbeatWidget` | ✅ (tap → open app to send) |
| Kiss | `KissWidget` | ✅ (tap → open app to send) |
| Emoji | `EmojiWidget` | ✅ (tap → open app to send) |

All **12** widgets are implemented natively on iOS.

### Interactive widgets (Heartbeat, Kiss, Emoji)

Tapping the widget opens the app via `lovelynk://widget/{heartbeat|kiss|emoji}?homeWidget` and shows the send dialog on the Widgets tab. The `homeWidget` query param is required for the `home_widget` plugin to deliver the URL to Flutter (`WidgetDeepLinkService`).

URL scheme `lovelynk` is registered in `ios/Runner/Info.plist`.

---

## Your Xcode checklist (first-time setup)

### 1. Apple Developer portal (one-time)

1. Go to [developer.apple.com](https://developer.apple.com) → Certificates, Identifiers & Profiles → **Identifiers**.
2. Open **App Groups** (or create one).
3. Register: **`group.com.lovelynk.ios`**  
   (If you still have `group.com.lovelynk.ios.widgetdemo`, you can delete it later — not needed anymore.)
4. Ensure your **App ID** for `com.lovelynk.ios` has App Groups capability enabled and includes `group.com.lovelynk.ios`.

### 2. Xcode — Runner app

1. Open **`ios/Runner.xcworkspace`**
2. Select **Runner** target → **Signing & Capabilities**
3. **App Groups** → remove old `widgetdemo` group if present
4. Add **`group.com.lovelynk.ios`** and check it ✅

### 3. Xcode — Widget extension

1. Select **LovelynkWidgetsExtension** target (was LoveWidgetExtension)
2. **Signing & Capabilities** → same App Group: **`group.com.lovelynk.ios`** ✅
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
3. Search **Lovelynk** → add any widget (Days Together, Heartbeat, etc.)
4. **Customise** tab → change colour → **Save** → widget updates

### 6. Lock screen

Long-press lock screen → Customize → add any Lovelynk widget

---

## How one App Group works for all widgets (and push updates)

You only need **one** App Group (`group.com.lovelynk.ios`). Think of it as a **shared folder** on the device that both the main app and the widget extension can read/write.

```
┌─────────────────────┐         ┌──────────────────────────┐
│  Lovelynk App       │  write  │  App Group (UserDefaults) │
│  (Flutter / Runner) │ ──────► │  group.com.lovelynk.ios   │
└─────────────────────┘         │                          │
                                │  days_together_count = 76 │
┌─────────────────────┐  read   │  partner_distance_miles=168│
│  Widget Extension   │ ◄────── │  anniversary_days_to_go=42  │
│  (SwiftUI / WidgetKit)        │  widget_global_locked = 0  │
└─────────────────────┘         └──────────────────────────┘
```

Each widget uses **different keys** inside the same group — like separate files in one folder. Updating `partner_distance_miles` does not touch `days_together_count`.

### When the app is open
`WidgetSyncService` writes keys → calls `HomeWidget.updateWidget(iOSName: "PartnerDistanceWidget")` → only that widget's timeline reloads.

### When the app is closed (push notification)
Widgets **cannot** run Flutter. Flow:

1. Partner's action updates **Supabase**
2. Supabase Edge Function sends **APNs** to your phone
3. **Notification Service Extension** (native Swift, not built yet) wakes briefly
4. Extension writes **only the changed keys** to the same App Group
5. Extension calls `WidgetCenter.shared.reloadTimelines(ofKind: "PartnerDistanceWidget")`
6. Widget extension reads App Group and redraws — **app never opened**

So yes — **one App Group is correct**. Push updates one widget by writing that widget's keys and reloading that widget's `kind`.

### What we have now vs later

| Piece | Status |
|-------|--------|
| App Group + key bridge | ✅ Done |
| Flutter sync on app open | ✅ Done |
| Per-widget native Swift UI | ✅ 12 of 12 |
| APNs + Notification Service Extension | 🔜 Phase 2 |
| `applyPushPayload()` in Dart | Stub ready |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Widget shows 0 / empty | Force-quit app and reopen |
| Build error duplicate `@main` | Only `LovelynkWidgetBundle.swift` has `@main` |
| App Group signing error | Match group id in portal + both targets |
| Old widget still on home screen | Remove old widget, add new from gallery |
| Lock screen shows "Please adopt containerBackground API" | Rebuild app after root `lovelynkContainerBackground`; **remove** old widgets from Home/Lock, then add again |
| Tap interactive widget does nothing | Rebuild after adding `lovelynk` URL scheme; URL must include `?homeWidget` |

---

## Adding a new widget (reference)

1. Dart: keys in `widget_app_group.dart` + `WidgetSyncService._writeDataFor`
2. Dart: `WidgetKind.implementedKinds`
3. iOS: `Widgets/YourWidget.swift` + keys in `WidgetKeys.swift`
4. iOS: register in `LovelynkWidgetBundle.swift`
