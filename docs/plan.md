# LoveLynk — Production Build Plan

The goal is to make every screen and all 12 widgets run on real data, end to end. Follow the phases **in order**. Each phase depends on the ones before it. Inside a phase, do the steps top to bottom.

**Scope for now:**
- **iOS only.** Android is out of scope until further notice.
- **One Supabase project** (`yvfolpaqchdmqdluprpo`) for everything. No separate dev or prod projects, no build flavours.
- **Keep the foundation simple.** The custom REST/Dio fetching files stay in the project for possible later use.

Every step is tagged with who does it:

- **[Dev]** — code: Flutter, Swift, SQL or Edge Functions.
- **[You]** — configuration only you can do: consoles, accounts, keys, store setup.
- **[Test]** — what has to pass before the step counts as done.

---

## 0. Where we are today (October 2026)

| Area | Status |
|---|---|
| Auth: sign up, email OTP, login, forgot/reset password | Real (Supabase) |
| Session bootstrap, `touch_session`, realtime pair/leave | Real |
| Connect with partner: invite code, accept, realtime + polling | Real |
| Database schema: users, couples, location, weather, interactions, notifications, push devices, subscriptions, storage, admin | Created and applied (16 migrations) |
| Interactions (heartbeat, kiss, emoji) | **Mock** — local counters only, never sent, partner side always 0 |
| Location, distance, compass | **Mock** — partner hard-coded to Sydney, distance always 0, own location never uploaded |
| Weather | **Mock** — 0° / "--"; no API, no Edge Function |
| Notifications screen | **Mock** — 6 hard-coded items; no FCM, no APNs |
| Subscription / paywall | **Mock** — Hive flag; no RevenueCat, no StoreKit |
| Profile: edit, avatar, settings, delete account, support | Placeholders or missing |
| 12 iOS widgets (home + lock screen) | UI done; data partly real, partly mock; no interactivity; no refresh while the app is closed |
| Edge Functions, cron jobs | None exist; `pg_cron` and `pg_net` not installed |

Already done in this round:
- [x] Connect screen: partner name is optional, "Skip this step" text, and "Go to Home" shown only after sign-up or first verification (`fromSignup` argument).
- [x] Pinput downgraded to 6.0.2 (fixes the Material crash).
- [x] Reset password returns to the existing Login route with `Get.until`.

---

## Phase 1 — Foundation and cleanup

*Why first:* every later phase builds on a correct logout and a clean starting point. Kept deliberately light.

### 1.1 Configuration
- [x] **[Dev]** Keep `AppConfig` as the single config file, pointing at the one Supabase project. No flavours, no env files.
- [x] **[Dev]** Add a `supabase/functions/` folder for the Edge Functions in later phases.

### 1.2 Light cleanup
- [x] **[Dev]** Keep the custom REST/Dio fetching files (`api_client.dart`, `api_endpoints.dart`, `auth_interceptor.dart`, the `ApiClient` registration) and the other template files for possible later use.
- [x] **[Dev]** Remove only what shows fake data or debug actions to users:
  - the demo Pinterest avatar URLs in `HelperUtils` (replaced by real avatars in Phase 2);
  - `WidgetsController.debugExpireTrial`.
- [x] **[Dev]** Fix `pubspec.yaml`: move `flutter_lints` under `dev_dependencies` (it is currently mis-indented) and fix the description.

### 1.3 Session hygiene
- [x] **[Dev]** Reset everything on logout and unexpected sign-out, in `SessionService._clearLocal` (account deletion will reuse it in Phase 2). It must:
  - Delete every user-scoped controller: Home, MainPage, Profile, Widgets, Customise, Notifications, Activities and the summary screens.
  - Reset `WidgetDataService` and `SubscriptionService`. The Hive subscription keys currently leak to the next account.
  - Clear the App Group widget data, so the partner's name and location are no longer on the lock screen, then reload all widgets.
  - Keep the Supabase session key safe. `SecureStorageService.clearAll` currently wipes it too, so scope the clear to app keys only.
- [x] **[Dev]** Onboarding: set `setOnBoardShowed` so onboarding only appears on first install.
- [x] **[Dev]** Login when the user is not paired: go to Connect (`fromSignup: true`) instead of Home.
- [x] **[Dev]** Main page: switch to `IndexedStack` so tabs keep their state.

### 1.4 Links from `app_settings`
- [x] **[Dev]** Read the public keys `terms_url`, `privacy_url` and `support_email` from `app_settings`, and use them for the Terms, Privacy and Contact links.
- [ ] **[You]** Host the Terms and Privacy pages (for example `lovelynk.io/terms` and `/privacy`) and set their URLs in `app_settings`.

**[Test]**
- A clean install shows onboarding once.
- Logout then login as a different user shows no old data, either in the app or in the widgets.

---

## Phase 2 — Profile, account and settings

*Why now:* everything here is account-level. Later phases add settings to these screens (location sharing, notifications, subscription).

### 2.1 Backend
- [x] **[Dev]** Migration `profile_account_rpcs`: RPC `update_my_profile(p_full_name, p_avatar_path)`. It trims the name, enforces 1–60 characters, checks that the avatar sits in the caller's `{uid}/` folder and exists, and broadcasts `couple.updated` to the partner. Direct `UPDATE` of `full_name`/`avatar_path` is revoked.
- [x] **[Dev]** Trigger `users_before_delete` on `public.users` (it runs for any deletion path). It archives the couple, broadcasts `couple.left`, removes the user's invites and increments `deleted_users`.
- [x] **[Dev]** Edge Function `delete-account`: verifies the JWT, removes the user's `avatars` and `support-attachments` folders, then deletes the auth user (the cascade fires the trigger above).
- [x] **[Dev]** RPC `submit_support_ticket(...)`, limited to 5 per day; attachment paths are checked.
- [x] **[Dev]** `app_settings.app_store_id` (public), used by the Rate Us fallback.

### 2.2 App
- [x] **[Dev]** Edit Profile screen: name, plus an avatar (take photo, choose or remove) resized to 512px as a JPEG and uploaded to `avatars/{uid}/avatar_<ts>.jpg`; the old file is deleted afterwards. Shown via signed URLs cached for 23 hours.
- [x] **[Dev]** Real avatars, with an initials fallback, on Home (you and your partner), the Profile header and Partner Profile.
- [x] **[Dev]** Partner Profile screen (read-only): avatar, name and nickname, together since, days together, local time and time zone city. It opens from Profile and from the partner avatar on Home.
- [x] **[Dev]** Settings screen: distance unit (mi/km, saved on the device, drives the Home chip), email, change password (re-checks the current password), app version, Delete Account.
  - Location sharing toggle → added in Phase 4.
  - Notification preferences → added in Phase 6.
- [x] **[Dev]** Contact Us form: topic, subject, message, up to 3 screenshots; sends the app version, device model and iOS version.
- [x] **[Dev]** Privacy Policy and Terms open the `app_settings` URLs. Rate Us uses `in_app_review`, falling back to the App Store page once `app_store_id` is set.
- [x] **[Dev]** Delete Account flow: type "DELETE", call `delete-account`, clear local data, then go to Login.
- [x] **[Dev]** Removed the placeholder fields from `ProfileController` (Phase 1).

**[Test]**
- An avatar uploaded by one partner shows on the other partner's phone.
- Deleting an account returns the partner to the unpaired state.
- Every Profile row does something.

---

## Phase 3 — Couple data and real-time partner sync

*Why now:* most widgets depend on couple fields (`together_since`, `next_visit_at`, nickname). Those fields must be editable and must sync live before we add location and interactions.

### 3.1 Backend (migration `couple_rpcs`)
- [x] **[Dev]** RPC `update_couple(p_together_since, p_next_visit_at, p_clear_together_since, p_clear_next_visit)`.
  - Dates are checked against the **user's own timezone** (`private.user_today`), so "today" works everywhere. If the zone is unknown it allows up to UTC+14.
  - `next_visit_at` must be today or later (local), within 3 years; it can be cleared.
  - Broadcasts `couple.updated` to the partner. Limited to 30 per hour.
- [x] **[Dev]** RPC `update_partner_nickname(p_nickname)`. The nickname is private to the user, so it isn't broadcast.
- [x] **[Dev]** Direct UPDATE grants and policies on `couples` and `couple_members` revoked; every change goes through the RPCs.
- [x] **[Dev]** `accept_invite`: the pairing race (`23505`) now returns a friendly `LK004`.
- [x] **[Dev]** Code-guessing limits on `accept_invite`: 20 wrong codes per user per day, plus a global breaker of 300 wrong codes per 10 minutes (`private.global_rate_limits`).
- [x] **[Dev]** `touch_session` broadcasts `couple.updated` when the user's timezone changes, so the partner's clock updates.

### 3.2 App
- [x] **[Dev]** `SessionService` refreshes on `couple.updated` (Phase 2).
- [x] **[Dev]** Shared `CoupleEditor`: anniversary and next-visit date pickers (change or remove), nickname sheet. Used from Home, Profile (Our Anniversary, Next Visit) and Partner Profile.
- [x] **[Dev]** "No date" states: `WidgetData` no longer falls back to "now"; the app shows "Set date" and the native widgets get empty values (Anniversary shows "Set your date in LoveLynk").
- [x] **[Dev]** Connect screen: an expired code renews automatically, and there's a "New code" link. `create_invite` already reuses the open code when the step opens.
  - Not done on purpose: cancelling the invite when leaving unpaired. People share the code and wait on Home, and pairing still notifies them there.
  - Optional universal link `https://lovelynk.io/join/{code}` → later (needs the domain).
- [x] **[Dev]** Home: time-of-day greeting, pull-to-refresh, an offline banner with Retry, a new "Our dates" card (days together, next visit, partner's local time), and tapping the widget previews opens the Widgets tab when unlocked.
- [x] **[Dev]** Partner Time uses the IANA timezone (Dart `timezone` package in the app; `TimeZone(identifier:)` in the native widget with a minutes-offset fallback). This fixes +5:30 / +5:45 offsets and DST.

**[Test]** When partner A edits the anniversary, partner B's app updates within about 1 second while open, or on next launch.

---

## Phase 4 — Location, distance and Love Compass

*Why now:* distance, the compass and weather all need real coordinates.

### 4.1 Strategy (agreed design)
- **Send on movement**, with thresholds that adapt to speed. Add a minimum time between sends and a heartbeat when the user is still.

  | State | Distance threshold | Minimum interval |
  |---|---|---|
  | Still or walking | 150 m | 1 min |
  | Driving | 1–2 km | 3–5 min |
  | Over 150 km/h (train, plane) | — | 15 min |
  | Heartbeat when not moving | — | 30–60 min (foreground) |

- Drop readings with accuracy worse than 100 m, and drop jumps that imply an impossible speed.
- Store **one row per user** (`user_locations`) and overwrite it. Coordinates are rounded to 4 decimal places (about 11 m).
- The partner **reads** the location when needed: on app open or resume, on Home, and on widget refresh. Realtime is used only while the compass screen is open.
- iOS background: use **significant location change** (about 500 m) first. Continuous background tracking is a later option, and needs "Always" permission plus a strong App Store justification.

### 4.2 Backend
- [x] **[Dev]** Migration: add RPC `update_my_location(lat, lng, accuracy_m, city, country_code)`. It:
  - rounds the coordinates;
  - throttles on the server (45-60 seconds, or less than 100 m);
  - returns `{accepted, next_allowed_at}`;
  - closes the delete-then-insert loophole in the throttle;
  - checks `location_sharing_enabled` first.
- [x] **[Dev]** Migration: add `users.location_sharing_enabled boolean default true`. When it is false, the partner's view of your location returns null and the app shows "Location paused".
- [x] **[Dev]** Add a view or RPC `get_partner_snapshot()` that returns the partner's location (lat, lng, city, updated_at), weather and timezone in one call. Add it to `get_session_bootstrap` as `partner_live`.
- [x] **[Dev]** Optional: when the location changes by more than 200 m, broadcast `partner.location` to the partner.

### 4.3 App
- [x] **[Dev]** Write a `LocationSyncService` that owns the gate logic above, adaptive speed-based tracking, and throttling handling.
- [x] **[Dev]** Permission flow:
  - Clear error states for GPS service disabled, denied, and denied forever.
  - Handle "denied forever" with direct link to iOS Settings.
  - Interactive tap on Home distance card to prompt or fix permissions.
- [x] **[Dev]** Reverse geocoding for `city`/`country_code` (the `geocoding` package, on device).
- [x] **[Dev]** `CompassService`: replace the hard-coded Sydney coordinates with the partner snapshot. Calculate bearing and distance from real coordinates, in the user's chosen unit.
- [x] **[Dev]** Home distance card and the Partner Distance widget data: real distance, "Together ❤️" proximity (< 80m), a "last updated" label, and a "location paused" state.
- [x] **[Dev]** Settings: the location sharing toggle calls the backend with instant UI update.
- [ ] **[You]** Write the App Store location usage text and privacy label: "Precise location — App Functionality — linked to user".

**[Test]**
- Two real devices show the correct distance and compass direction.
- About 10–20 writes per hour while driving.
- No writes while sitting still, apart from the heartbeat.
- Turning sharing off hides your location from the partner.

---

## Phase 5 — Partner weather

*Depends on Phase 4 (coordinates).*

- [ ] **[You]** Create an OpenWeather account and API key, and add it as a Supabase secret `OPENWEATHER_API_KEY`.
- [x] **[Dev]** Edge Function `refresh-weather`, which:
  1. takes a `user_id` (or is called for the caller);
  2. reads `user_locations`;
  3. skips the call if `user_weather.fetched_at` is less than 30 minutes old and user hasn't forced refresh;
  4. calls OpenWeather `/weather`;
  5. upserts `user_weather` and broadcasts `partner.weather` to partner channel.
- [x] **[Dev]** Trigger weather refresh on location update, on session bootstrap when stale, and on Home pull-to-refresh.
- [x] **[Dev]** App: fill `PartnerWeather.fromOpenWeather` from `get_partner_snapshot`. Show partner weather and temperature on Home dates card with day/night icon, and add temperature unit preference (°C / °F) in Settings.

**[Test]** The partner's weather matches their real city, the icon shows day or night correctly, and the API is called no more than about 2 times per user per hour.

---

## Phase 6 — Push notifications and the notification centre

*Why before interactions:* sending a heartbeat, kiss or emoji is useless unless the partner gets a push, and widgets can only refresh while the app is closed through push.

### 6.1 Configuration
- [ ] **[You]** Create a Firebase project "LoveLynk" with one iOS app, `com.lovelynk.ios`.
- [ ] **[You]** Apple Developer:
  - Create an **APNs Auth Key (.p8)** and upload it to Firebase Cloud Messaging.
  - Turn on Push Notifications for `com.lovelynk.ios`.
  - Regenerate the provisioning profiles.
- [ ] **[You]** Download `GoogleService-Info.plist` and share it securely.
- [ ] **[You]** Create a Firebase service account JSON and add it as the Supabase secret `FIREBASE_SERVICE_ACCOUNT`.
- [ ] **[Dev]** Xcode setup:
  - `aps-environment` entitlement.
  - `UIBackgroundModes: remote-notification`.
  - A new **Notification Service Extension** target in the same App Group, used for widget refresh in Phase 8.

### 6.2 Backend
- [ ] **[Dev]** Migration: add RPCs:
  - `register_push_device(token, platform, app_version)`, which upserts on `fcm_token` and moves the token to the new user if it already exists;
  - `unregister_push_device(token)`;
  - `mark_notifications_read(ids)`, `mark_all_notifications_read()` and `unread_notification_count()`;
  - `get_notification_preferences()` and `update_notification_preferences(...)`.
- [ ] **[Dev]** Edge Function `push-dispatch`. It:
  - is called by a database webhook on `notifications` insert;
  - checks the user's preferences and quiet hours (in the user's timezone);
  - sends FCM to every one of the user's devices, with the badge set to the unread count;
  - deletes tokens that FCM reports as invalid.
- [ ] **[Dev]** Write `notifications` rows for these events:
  - partner paired or left;
  - anniversary or next visit changed by the partner;
  - interactions (Phase 7);
  - subscription events (Phase 9);
  - announcements.
- [ ] **[Dev]** Security fix: hide `push_devices.fcm_token` from admins with a column grant or a view.

### 6.3 App
- [ ] **[Dev]** Add `firebase_core`, `firebase_messaging` and `flutter_local_notifications`.
- [ ] **[Dev]** Ask for notification permission after pairing.
- [ ] **[Dev]** Register the token on login and on token refresh. Unregister it on logout.
- [ ] **[Dev]** Handle the three cases: app in the foreground (in-app banner), in the background, and opened from a terminated state.
- [ ] **[Dev]** Deep-link router: map `data.route` to a screen (Heartbeat, Kiss or Emoji summary, Notifications, Profile, Subscriptions).
- [ ] **[Dev]** Notifications screen:
  - Use the real `notifications` table, with cursor pagination.
  - Pull-to-refresh.
  - Swipe to delete.
  - Mark read when tapped.
  - Show a live unread **badge** on `NotificationBellButton`, updated by a realtime `notification.new` broadcast.
- [ ] **[Dev]** Notification preferences screen in Settings: heartbeat, kiss, emoji, relationship, subscription, announcements, and quiet hours.

**[Test]**
- A push arrives with the app in the foreground, in the background, and after the app was killed.
- Tapping a push opens the right screen.
- Quiet hours are respected.
- After logout, that device receives no pushes.

---

## Phase 7 — Interactions: heartbeat, kiss and emoji

*Depends on Phases 3 and 6.*

### 7.1 Backend
- [ ] **[Dev]** Migration: add RPC `send_interaction(p_kind, p_count, p_emoji)`. It:
  - requires an active couple;
  - is rate-limited (for example 60 per minute and 1,000 per day per kind);
  - inserts into `interactions` and upserts `interaction_totals` (`total`, `recent_emojis` up to 9, `last_sent_at`);
  - creates a `notifications` row for the partner, whose push is grouped or collapsed so that 10 quick taps produce one push;
  - broadcasts `interaction.new` to the partner;
  - returns the new totals.
- [ ] **[Dev]** Migration: add RPC `get_interaction_summary()`. It returns, for each kind, totals from the partner and from me, today's counts, the partner's 3 most recent emojis, and the last sent time.
- [ ] **[Dev]** Migration: add RPC `get_interaction_feed(p_kind, p_before, p_limit)`, cursor-paginated, for Activities and the summary screens.
- [ ] **[Dev]** Security fix: stop admins reading `interaction_totals.recent_emojis`.

### 7.2 App
- [ ] **[Dev]** Write an `InteractionRepository` and replace the mock counters and lists in `WidgetDataService` with server data, kept in memory for the session.
- [ ] **[Dev]** Optimistic send: update the UI straight away, roll back on error, and **combine quick taps** into one RPC call (for example 600 ms debounce with `count = n`).
- [ ] **[Dev]** Realtime `interaction.new`: update counts and the feed, show an in-app "Milla sent you a kiss 💋", and sync the widgets.
- [ ] **[Dev]** Heartbeat, Kiss and Emoji summary screens:
  - Real "from partner" and "from me" totals.
  - Today's list and history with pagination.
  - Loading, empty and error states.
  - Remove the fake "sent" snackbars.
- [ ] **[Dev]** Activities screen: real merged feed with pagination and filters.
- [ ] **[Dev]** Home "Recent activity": the latest 3 items from the feed.
- [ ] **[Dev]** The "Send them the setup guide →" tip sends a real share link or push to the partner.

**[Test]**
- When partner A sends 5 heartbeats, partner B's counter shows +5 within about 1 second while their app is open, and B gets one grouped push.
- After a restart, the counts are still there.
- The rate limit shows a friendly message.

---

## Phase 8 — The 12 widgets: production pass

*Depends on Phases 3–7, which provide all real data.*

### 8.1 Data correctness, per widget

| # | Widget | Change needed |
|---|---|---|
| 1 | Partner Distance | Real distance in the chosen unit, plus a "last updated" age; show a "paused" state when sharing is off. |
| 2 | Days Together | Store `together_since` and **calculate in Swift**, so the count rolls over at midnight without the app opening. |
| 3 | Together Counter | Replace the 60 one-second entries with `Text(date, style: .timer)` / `WidgetLiveTimer`. Use a days + hh:mm:ss format. |
| 4 | Partner Time | Use the IANA timezone with `TimeZone(identifier:)` in Swift; the clock uses `Text(date, style: .time)` with one timeline entry per minute. |
| 5 | Partner Weather | Real weather from Phase 5, with an "as of" time. |
| 6 | Next Visit | Real `next_visit_at`, shown with `.timer` style; "Set a date" when empty. |
| 7 | Love Compass | Widgets can't read the device heading, so show **distance + direction to the partner**, with an arrow relative to north, instead of a frozen needle. |
| 8 | Initials | Remove the J/M fallback; show a neutral placeholder. |
| 9 | Anniversary | Store the date and calculate days-to-go in Swift. |
| 10 | Heartbeat | Partner's real total. |
| 11 | Kiss | Partner's real total. |
| 12 | Emoji | Partner's 3 most recent emojis. |

For all 12:
- [x] **[Dev]** A shared "not paired" state and a "signed out" state.
- [x] **[Dev]** Privacy: mark partner name and location with `.privacySensitive()` so they are hidden on the locked lock screen.
- [x] **[Dev]** Tested in the `accented` / `vibrant` rendering modes and the iOS 18 tinted home screen.
- [x] **[Dev]** Clear data when the subscription lock is active, not just the lock flag.

### 8.2 Refresh while the app is closed
- [x] **[Dev]** The Notification Service Extension from Phase 6 reads the widget payload from push data (for example `widget: {kind, keys}`), writes the App Group keys, and calls `WidgetCenter.shared.reloadTimelines(ofKind:)`.
- [x] **[Dev]** `push-dispatch` attaches a widget payload to interaction, location and weather events. Silent pushes are only a best-effort fallback.
- [x] **[Dev]** Timeline policy: interaction widgets `.after(30 min)`; distance and weather `.after(30–60 min)`; date widgets `.after(midnight)`.

### 8.3 Taps and interactivity
- [x] **[Dev]** Each widget gets its own `widgetURL`, for example `lovelynk://widget/heartbeat`. `WidgetDeepLinkService` routes it to the right screen, and waits until the session is ready.
- [x] **[Dev]** **Interactive send on iOS 17+:** `AppIntent` + `Button(intent:)` on Heartbeat, Kiss and Emoji. The intent calls `send_interaction` straight from the extension.
  - The extension gets a short-lived access token and refresh token through a **shared Keychain access group**.
  - On iOS 16 it falls back to opening the app.
  - The widget descriptions must match the real behaviour ("Tap to send one back").
- [ ] **[You]** Turn on the Keychain Sharing capability for both targets, and regenerate the profiles.
- [x] **[Dev]** Update `docs/WIDGET_NATIVE_SETUP.md` to match the code.

**[Test]**
- All 12 widgets show real data on the home screen and in all 3 lock screen sizes.
- The partner's kiss updates the widget within about a minute while the app is killed.
- Tapping Heartbeat on the widget sends one without opening the app (iOS 17+).
- Logout clears every widget.

---

## Phase 9 — Subscriptions (RevenueCat)

*Can start configuration in parallel with Phase 6; the code is done here, because widget locking and partner-shared premium rely on everything above.*

### 9.1 Configuration
- [ ] **[You]** App Store Connect:
  - Sign the **Paid Apps agreement** and add tax and banking details.
  - Create a subscription group "LoveLynk Plus" with **monthly £6.99** and **yearly £29.99**, each with a **7-day free trial** (introductory offer).
  - Add localisations and review screenshots.
- [ ] **[You]** Create the App Store Connect **In-App Purchase key** (and the App Store Server Notifications URL, pointed at RevenueCat).
- [ ] **[You]** Create the RevenueCat project:
  - Add the iOS app and the IAP key.
  - Entitlement `plus`; offering `default` with the monthly and yearly packages.
  - Webhook URL set to the Supabase Edge Function, with an auth header (`REVENUECAT_WEBHOOK_AUTH` secret).
### 9.2 Backend
- [x] **[Dev]** Edge Function `revenuecat-webhook`. It:
  - checks the auth header and skips duplicate events (idempotent on `event_id`);
  - logs each event to `private.revenuecat_events`;
  - upserts `subscription_entitlements` and inserts `subscription_transactions`;
  - creates subscription notifications: trial ending, billing issue, expired;
  - broadcasts `access.changed` to the user **and their partner**, because premium is shared through the partner.

### 9.3 App
- [x] **[Dev]** Add `purchases_flutter`. Call `Purchases.logIn(supabaseUserId)` after login and `logOut` on logout.
- [x] **[Dev]** Rebuild `SubscriptionService` to read the **server** `access` (from the bootstrap plus `access.changed`) as the source of truth, with RevenueCat `CustomerInfo` for an instant update after purchase. Delete the Hive mock.
- [x] **[Dev]** Paywall:
  - Localised prices from offerings.
  - Trial eligibility.
  - Purchase, restore and cancelled-purchase states.
  - Real Terms and Privacy links.
  - "Manage subscription" through `showManageSubscriptions`.
- [x] **[Dev]** Lock rules: what free users see, and what Plus (yours or your partner's) unlocks. Applies to the widgets, Customise and the Home previews. Fix the trial banner text for users who never started a trial.
- [x] **[Dev]** Profile: subscription status row, showing "Plus via Milla" when premium comes from the partner.

**[Test]**
- A sandbox purchase unlocks the buyer **and** the partner within seconds.
- Cancel then expire locks both.
- Restore works.
- After a refund, access is removed.

---

## Phase 10 — Backend operations, security and data retention

### 10.1 Scheduled jobs (install `pg_cron` and `pg_net`)
- [ ] **[Dev]** `refresh_active_weather` every 30–60 minutes.
- [ ] **[Dev]** `dispatch_scheduled_broadcasts` every 5 minutes, using Edge Function `broadcast-dispatch` (batches of 500).
- [ ] **[Dev]** `anniversary_reminders` daily, in each user's timezone.
- [ ] **[Dev]** `compute_daily_metrics` daily.
- [ ] **[Dev]** Purges:
  - interactions older than 90 days (keep the totals);
  - notifications older than 90 days;
  - consumed or expired invites;
  - `rate_limits` and `global_rate_limits` windows;
  - archived couples past `purge_after`;
  - stale push devices (90 days);
  - RevenueCat events (180 days);
  - unverified auth users older than 7 days.

### 10.2 Security hardening
- [ ] **[You]** Supabase Auth:
  - Turn on **leaked-password protection**.
  - Set up **custom SMTP via Resend** with SPF, DKIM and DMARC on `lovelynk.io` in GoDaddy DNS.
  - Brand the OTP email template.
  - Turn on Realtime "private channels only".
- [ ] **[Dev]** Require `aal2` (MFA) in `private.is_admin()`.
- [ ] **[Dev]** Enforce `users.banned_at` in `require_app_user()`.
- [ ] **[Dev]** Check that the `private` schema is not exposed by the Data API.
- [ ] **[Dev]** Run the Supabase security and performance advisors and fix every warning.

### 10.3 Admin panel (separate track)
- [ ] **[Dev]** RPCs: `admin_list_users`, `admin_list_couples`, `admin_dashboard_today`, `admin_update_ticket` (the reply creates a notification), `admin_create_broadcast` / `admin_cancel_broadcast`, `admin_update_setting`.
- [ ] **[Dev]** Edge Function `admin-manage`: create or deactivate admins; ban, unban or delete users (archiving the couple first).
- [ ] **[You]** Decide the admin panel stack and hosting (for example Next.js on Vercel).

---

## Phase 11 — QA, compliance and release

- [ ] **[Dev]** Tests:
  - Unit tests for location gating, distance and bearing, and the widget data builders.
  - A two-device end-to-end checklist: pairing, interactions, location, push, purchase.
- [ ] **[Dev]** Localisation-ready strings, and accessibility (Dynamic Type, VoiceOver labels on widgets).
- [ ] **[Dev]** Performance: app start under 2 seconds, no rebuild storms in `Obx`, image caching.
- [ ] **[You]** App Store privacy labels: email, name, precise location, user content (interactions), purchases, identifiers (FCM).
- [ ] **[You]** App Review notes:
  - A demo couple: two test accounts that are already paired.
  - The location justification.
  - Where to find account deletion.
- [ ] **[You]** Store listing: screenshots of the widgets and lock screen, the description, keywords, and the support URL.
- [ ] **[Dev]** Release pipeline: version bump, `flutter build ipa`, TestFlight, then the production release.

---

## Configuration checklist (your side, collected in one place)

| When | Item |
|---|---|
| Phase 1 | Terms/Privacy pages hosted → set `terms_url`, `privacy_url`, `support_email` in `app_settings` |
| Phase 2 | `app_store_id` in `app_settings` once the App Store record exists |
| Phase 4 | Location usage text and privacy label |
| Phase 5 | OpenWeather API key → Supabase secret |
| Phase 6 | Firebase project (iOS app) · APNs .p8 key → Firebase · Push capability · `GoogleService-Info.plist` · Firebase service account → Supabase secret |
| Phase 8 | Keychain Sharing capability on both targets · regenerate profiles |
| Phase 9 | Paid Apps agreement · subscription products + trials · IAP key · RevenueCat project, entitlement, offering, webhook secret |
| Phase 10 | Leaked-password protection · Resend SMTP + GoDaddy DNS (SPF/DKIM/DMARC) · Realtime private-only · admin panel hosting |
| Phase 11 | Privacy labels · review demo accounts · store listing |

## Decisions needed before their phase

1. **Background location (Phase 4):** start with "while using" plus iOS significant-change, or go straight to "Always" continuous tracking?
2. **Interactive widgets (Phase 8):** is iOS 17+ one-tap send required? On iOS 16 it would open the app instead.
3. **What is free and what is Plus (Phase 9):** which widgets and features are free?
4. **Sign in with Apple / Google:** not planned. If you add a third-party login later, Apple requires Sign in with Apple too.
