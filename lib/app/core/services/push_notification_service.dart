import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:home_widget/home_widget.dart';

import '../../../firebase_options.dart';
import '../../data/repositories/notification_repository.dart';
import '../../routes/app_pages.dart';
import '../network/supabase/supabase_service.dart';
import '../utils/logger.dart';
import '../widgets/widget_app_group.dart';
import '../widgets/widget_sync_service.dart';
import 'session_service.dart';
import 'widget_data_service.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  Log.i('[FCM Background] Message received: ${message.messageId}, data: ${message.data}');

  try {
    await HomeWidget.setAppGroupId(WidgetAppGroup.id);
    final data = message.data;
    final kind = (data['kind'] ?? data['category'] ?? '').toString();
    final countStr = data['count']?.toString() ?? '1';
    final count = int.tryParse(countStr) ?? 1;
    final totalStr = data['total']?.toString();

    if (kind == 'heartbeat') {
      int newCount;
      if (totalStr != null && int.tryParse(totalStr) != null) {
        newCount = int.parse(totalStr);
      } else {
        final currentStr =
            await HomeWidget.getWidgetData<String>(WidgetAppGroup.heartbeatCount) ?? '0';
        final current = int.tryParse(currentStr) ?? 0;
        newCount = current + count;
      }
      await HomeWidget.saveWidgetData<String>(WidgetAppGroup.heartbeatCount, '$newCount');
      await HomeWidget.updateWidget(iOSName: 'HeartbeatWidget');
      Log.i('[FCM Background] Updated HeartbeatWidget count to $newCount');
    } else if (kind == 'kiss') {
      int newCount;
      if (totalStr != null && int.tryParse(totalStr) != null) {
        newCount = int.parse(totalStr);
      } else {
        final currentStr =
            await HomeWidget.getWidgetData<String>(WidgetAppGroup.kissCount) ?? '0';
        final current = int.tryParse(currentStr) ?? 0;
        newCount = current + count;
      }
      await HomeWidget.saveWidgetData<String>(WidgetAppGroup.kissCount, '$newCount');
      await HomeWidget.updateWidget(iOSName: 'KissWidget');
      Log.i('[FCM Background] Updated KissWidget count to $newCount');
    } else if (kind == 'emoji') {
      final emoji = data['emoji']?.toString();
      final recentEmojisStr = data['recent_emojis']?.toString();
      if (recentEmojisStr != null && recentEmojisStr.isNotEmpty) {
        final top3 = recentEmojisStr.split(',').take(3).join(',');
        await HomeWidget.saveWidgetData<String>(WidgetAppGroup.emojiRecent, top3);
      } else if (emoji != null && emoji.isNotEmpty) {
        final currentStr =
            await HomeWidget.getWidgetData<String>(WidgetAppGroup.emojiRecent) ?? '';
        final list = currentStr.split(',').where((e) => e.isNotEmpty).toList();
        list.remove(emoji);
        list.insert(0, emoji);
        final updated = list.take(3).join(',');
        await HomeWidget.saveWidgetData<String>(WidgetAppGroup.emojiRecent, updated);
      }
      await HomeWidget.updateWidget(iOSName: 'EmojiWidget');
      Log.i('[FCM Background] Updated EmojiWidget');
    }
  } catch (e) {
    Log.w('[FCM Background] Error updating widget: $e');
  }
}

class PushNotificationService extends GetxService {
  static PushNotificationService get to => Get.find<PushNotificationService>();

  final RxInt unreadCount = 0.obs;
  final RxBool isRegistered = false.obs;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _badgeChannel =
      MethodChannel('com.lovelynk.app/badge');

  StreamSubscription<String>? _tokenRefreshSub;
  Worker? _sessionWorker;
  Worker? _badgeWorker;

  INotificationRepository get _repo {
    if (!Get.isRegistered<INotificationRepository>()) {
      Get.lazyPut<INotificationRepository>(
        () => NotificationRepository(Get.find<SupabaseService>()),
        fenix: true,
      );
    }
    return Get.find<INotificationRepository>();
  }

  Future<PushNotificationService> init() async {
    // Ensure Firebase is initialized if not already done in main()
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        Log.i('[FCM] Firebase initialized in PushNotificationService');
      } catch (e) {
        Log.w('[FCM] Firebase initialization warning: $e');
      }
    }

    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      Log.w('[FCM] Error registering background handler: $e');
    }

    await _initLocalNotifications();
    await _initMessaging();
    _bindSessionListener();
    _bindBadgeListener();

    return this;
  }

  void _bindBadgeListener() {
    // Immediately sync app badge on start and on every count update
    _badgeWorker = ever<int>(unreadCount, (count) {
      updateAppBadge(count);
    });
  }

  /// Sets the native app icon badge count via MethodChannel on iOS
  Future<void> updateAppBadge(int count) async {
    if (!Platform.isIOS) return;
    try {
      await _badgeChannel.invokeMethod('setBadge', count);
      Log.i('[Badge] Synced native app badge to: $count');
    } catch (e) {
      Log.w('[Badge] Failed to sync native app badge: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: true,
      requestSoundPermission: false,
      defaultPresentBadge: true,
    );

    const initSettings = InitializationSettings(
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    // Named parameter 'settings' required in flutter_local_notifications >= 22.0
    await _localNotifs.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _handleDeepLink(payload);
        } else {
          Get.toNamed(Routes.NOTIFICATIONS);
        }
      },
    );
  }

  Future<void> _initMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request notification permissions on iOS
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      Log.i('[FCM] User notification authorization: ${settings.authorizationStatus}');

      // Enable foreground notification presentation options
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for foreground FCM messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Listen for notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Log.i('[FCM] Notification opened from background: ${message.data}');
        final route = message.data['route'] as String?;
        _handleDeepLink(route);
      });

      // Check if opened from a terminated state
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        Log.i('[FCM] App launched from terminated state via message: ${initialMessage.data}');
        final route = initialMessage.data['route'] as String?;
        if (route != null && route.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleDeepLink(route);
          });
        }
      }

      // Listen for registered / refreshed tokens using FCM 17 onRegistered API
      _tokenRefreshSub = messaging.onRegistered.listen((newToken) {
        Log.i('[FCM] Token onRegistered: $newToken');
        _fcmToken = newToken;
        _registerWithToken(newToken);
      });

      // Poll and log APNs + FCM tokens as soon as notification permission is granted
      unawaited(_fetchAndLogTokens(messaging));
    } catch (e) {
      Log.w('[FCM] Messaging setup warning: $e');
    }
  }

  /// Polls for APNs token on iOS and logs both APNs and FCM tokens
  Future<void> _fetchAndLogTokens(FirebaseMessaging messaging) async {
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          try {
            apnsToken = await messaging.getAPNSToken();
            if (apnsToken != null && apnsToken.isNotEmpty) {
              break;
            }
          } catch (e) {
            Log.w('[APNs] Polling APNs token error: $e');
          }
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken != null && apnsToken.isNotEmpty) {
          Log.i('========================================');
          Log.i('[APNs] 📱 Device APNs Token: $apnsToken');
          Log.i('========================================');
        } else {
          Log.w('[APNs] ⚠️ APNs Token not returned yet by iOS (APNs registration pending)');
        }
      }

      // Register with Firebase Cloud Messaging
      try {
        await messaging.register();
      } catch (e) {
        Log.w('[FCM] messaging.register() notice: $e');
      }

      // Retrieve FCM Token
      try {
        // ignore: deprecated_member_use
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          _fcmToken = token;
          Log.i('========================================');
          Log.i('[FCM] 🔑 Device FCM Token: $token');
          Log.i('========================================');
          await _registerWithToken(token);
        }
      } catch (e) {
        Log.w('[FCM] messaging.getToken() error: $e');
      }
    } catch (e) {
      Log.w('[FCM] Token fetch error: $e');
    }
  }

  void _bindSessionListener() {
    if (Get.isRegistered<SessionService>()) {
      final session = Get.find<SessionService>();
      _sessionWorker = ever(session.bootstrap, (bootstrap) {
        if (bootstrap != null) {
          registerDevice();
          refreshUnreadCount();
        } else {
          unregisterDevice();
        }
      });
    }
  }

  /// Handles incoming foreground FCM message
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    Log.i('[FCM] Foreground notification: ${message.notification?.title} - ${message.notification?.body}');

    // Refresh unread count
    await refreshUnreadCount();

    // Trigger widget sync so iOS lock/home screen widgets update immediately
    if (Get.isRegistered<WidgetDataService>()) {
      try {
        await Get.find<WidgetDataService>().refreshFromBackend();
      } catch (e) {
        Log.w('[FCM] WidgetData refresh error on foreground push: $e');
      }
    } else if (Get.isRegistered<WidgetSyncService>()) {
      try {
        await Get.find<WidgetSyncService>().syncAll();
      } catch (e) {
        Log.w('[FCM] Widget sync error on foreground push: $e');
      }
    }

    // Show local notification alert if notification payload is present
    final notif = message.notification;
    if (notif != null && (notif.title != null || notif.body != null)) {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final route = message.data['route'] as String? ?? Routes.NOTIFICATIONS;

      // flutter_local_notifications >= 22.0 uses named parameters for show()
      await _localNotifs.show(
        id: id,
        title: notif.title ?? 'LoveLynk',
        body: notif.body ?? '',
        notificationDetails: NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: unreadCount.value,
          ),
        ),
        payload: route,
      );
    }
  }

  /// Registers current device with Firebase Cloud Messaging and Supabase
  Future<void> registerDevice() async {
    if (!Get.isRegistered<SupabaseService>()) return;
    final supa = Get.find<SupabaseService>();
    if (supa.currentUser == null) return;

    final token = _fcmToken;
    if (token != null && token.isNotEmpty) {
      await _registerWithToken(token);
    } else {
      final messaging = FirebaseMessaging.instance;
      await _fetchAndLogTokens(messaging);
    }
  }

  Future<void> _registerWithToken(String token) async {
    if (!Get.isRegistered<SupabaseService>()) return;
    final supa = Get.find<SupabaseService>();
    if (supa.currentUser == null) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      final platform = Platform.isIOS ? 'ios' : 'android';

      await _repo.registerPushDevice(
        fcmToken: token,
        platform: platform,
        appVersion: appVersion,
      );
      isRegistered.value = true;
      Log.i('[FCM] Device registered successfully with Supabase');
    } catch (e) {
      Log.w('[FCM] Device registration failed: $e');
    }
  }

  /// Unregisters device FCM token on logout
  Future<void> unregisterDevice() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;

    try {
      await _repo.unregisterPushDevice(token);
      Log.i('[FCM] Device unregistered successfully');
    } catch (e) {
      Log.w('[FCM] Device unregister failed: $e');
    } finally {
      isRegistered.value = false;
      unreadCount.value = 0;
    }
  }

  /// Refreshes reactive unread count from Supabase
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repo.getUnreadCount();
      unreadCount.value = count;
      Log.i('[FCM] Unread notification count: $count');
    } catch (e) {
      Log.w('[FCM] Failed to refresh unread count: $e');
    }
  }

  /// Realtime event handler called when a new notification is broadcasted
  Future<void> handleRealtimeNotification(Map<String, dynamic> payload) async {
    Log.i('[FCM] Realtime notification received: $payload');
    unreadCount.value++;
    if (Get.isRegistered<WidgetSyncService>()) {
      try {
        await Get.find<WidgetSyncService>().syncAll();
      } catch (e) {
        Log.w('[FCM] Realtime widget sync error: $e');
      }
    }
  }

  void _handleDeepLink(String? route) {
    if (route == null || route.isEmpty) {
      Get.toNamed(Routes.NOTIFICATIONS);
      return;
    }

    try {
      if (Get.currentRoute == route) return;
      Get.toNamed(route);
    } catch (e) {
      Log.w('[FCM] Navigation to $route failed, falling back to notifications: $e');
      Get.toNamed(Routes.NOTIFICATIONS);
    }
  }

  @override
  void onClose() {
    _tokenRefreshSub?.cancel();
    _sessionWorker?.dispose();
    _badgeWorker?.dispose();
    super.onClose();
  }
}
