import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../data/models/widget_models/app_widget_type.dart';
import '../../data/models/widget_models/widget_style.dart';
import '../services/compass_service.dart';
import '../services/session_service.dart';
import '../services/subscription_service.dart';
import '../services/widget_data_service.dart';
import '../utils/logger.dart';
import '../utils/weather_icon_mapper.dart';
import 'widget_app_group.dart';
import '../widgets/widget_style_store.dart';
import 'widget_kind.dart';

/// Central bridge between Flutter and native WidgetKit via the App Group.
///
/// Responsibilities:
/// - Write widget **data** (from [WidgetDataService] / Supabase)
/// - Write widget **styles** (from customise screen)
/// - Write global **lock** state and paired status
/// - Clear data when subscription lock is active
/// - Trigger native timeline reloads (`HomeWidget.updateWidget`)
/// - [applyPushPayload] — entry point when a push notification arrives
class WidgetSyncService extends GetxService {
  late final WidgetDataService _data;
  late final SubscriptionService _subscription;

  Future<WidgetSyncService> init() async {
    await HomeWidget.setAppGroupId(WidgetAppGroup.id);
    _data = Get.find<WidgetDataService>();
    _subscription = Get.find<SubscriptionService>();
    await syncOnAppLaunch();
    return this;
  }

  /// Called on every cold start.
  Future<void> syncOnAppLaunch() async {
    Log.i('[WidgetSync] App opening — starting widget sync...');
    await _data.refreshFromBackend();
    await syncAll();
    Log.i('[WidgetSync] App opening sync complete.');
  }

  /// Full sync — call after login, partner connect, or manual refresh.
  Future<void> syncAll() async {
    final locked = _locked;
    Log.i(
      '[WidgetSync] syncAll — locked=$locked, '
      'paired=$isPaired, '
      'premium=${_subscription.isPremium}, '
      'onTrial=${_subscription.isOnTrial}',
    );

    await _writeGlobalStatus();

    if (locked) {
      // Per Phase 8 requirements: clear data when subscription lock is active
      for (final key in WidgetAppGroup.dataKeys) {
        if (key != WidgetAppGroup.globalLocked &&
            key != WidgetAppGroup.globalLockMessage) {
          await HomeWidget.saveWidgetData<String>(key, '');
        }
      }
    } else {
      for (final type in AppWidgetType.values) {
        await _writeDataFor(type);
      }
    }

    // Always sync styles (styles are local device preferences)
    for (final type in AppWidgetType.values) {
      if (WidgetKind.hasNativeImplementation(type) &&
          Get.isRegistered<WidgetStyleStore>()) {
        final styleStore = Get.find<WidgetStyleStore>();
        final style = await styleStore.load(type);
        await _writeStyleFor(type, style);
      }
    }

    await _refreshAllNativeWidgets();
    Log.i('[WidgetSync] syncAll finished — native widgets refreshed.');
  }

  /// Sync one widget's data + refresh its native timeline.
  Future<void> syncWidget(AppWidgetType type) async {
    await _writeGlobalStatus();
    if (!_locked) {
      await _writeDataFor(type);
    }
    await _refreshNativeWidget(type);
  }

  /// After customise save — rewrite style keys and refresh native widget.
  Future<void> syncStyle(AppWidgetType type, WidgetStyle style) async {
    await _writeStyleFor(type, style);
    await _refreshNativeWidget(type);
  }

  /// Push notification handler: Parses incoming FCM / APNs background payload and refreshes widgets.
  Future<void> applyPushPayload(Map<String, dynamic> payload) async {
    Log.i('[WidgetSync] applyPushPayload: $payload');
    final kind = payload['kind'] as String? ?? payload['category'] as String?;

    if (kind == 'heartbeat') {
      await syncWidget(AppWidgetType.heartbeat);
      return;
    } else if (kind == 'kiss') {
      await syncWidget(AppWidgetType.kiss);
      return;
    } else if (kind == 'emoji') {
      await syncWidget(AppWidgetType.emoji);
      return;
    } else if (kind == 'location' || kind == 'partner.location') {
      await syncWidget(AppWidgetType.partnerDistance);
      await syncWidget(AppWidgetType.loveCompass);
      return;
    } else if (kind == 'weather' || kind == 'partner.weather') {
      await syncWidget(AppWidgetType.partnerWeather);
      return;
    }

    await syncAll();
  }

  /// Logout / account switch: removes every per-user value so the previous
  /// user's data (partner name, location…) never stays on the lock screen.
  Future<void> clearUserData() async {
    for (final key in WidgetAppGroup.dataKeys) {
      await HomeWidget.saveWidgetData<String>(key, '');
    }
    await _writeGlobalStatus();
    await _refreshAllNativeWidgets();
    Log.i('[WidgetSync] User data cleared from widgets.');
  }

  // ── Global status ────────────────────────────────────────────────────────

  bool get _signedIn => SessionService.to.hasSession;

  bool get isPaired => SessionService.to.isPaired;

  bool get _locked => !_signedIn || !_subscription.isWidgetsUnlocked;

  Future<void> _writeGlobalStatus() async {
    final locked = _locked;
    await HomeWidget.saveWidgetData<String>(
      WidgetAppGroup.globalLocked,
      locked ? '1' : '0',
    );
    await HomeWidget.saveWidgetData<String>(
      WidgetAppGroup.isPaired,
      isPaired ? '1' : '0',
    );

    final d = _data.data.value;
    final pName = d.partnerName.trim();
    await HomeWidget.saveWidgetData<String>(
      WidgetAppGroup.partnerName,
      pName.isEmpty ? 'Partner' : pName,
    );

    if (locked) {
      await HomeWidget.saveWidgetData<String>(
        WidgetAppGroup.globalLockMessage,
        _signedIn
            ? (_subscription.widgetLockMessage ?? 'Locked')
            : 'Sign in to LoveLynk',
      );
    } else if (!isPaired) {
      await HomeWidget.saveWidgetData<String>(
        WidgetAppGroup.globalLockMessage,
        'Connect with your partner',
      );
    }
  }

  // ── Per-widget data ─────────────────────────────────────────────────────

  Future<void> _writeDataFor(AppWidgetType type) async {
    if (_locked) return;

    final d = _data.data.value;
    switch (type) {
      case AppWidgetType.daysTogether:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.daysTogetherCount,
          '${d.daysTogether ?? 0}',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.daysTogetherSince,
          d.togetherSince?.toUtc().toIso8601String() ?? '',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.daysTogetherTitle,
          'Days Together',
        );
        break;

      case AppWidgetType.initials:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.initialsUser,
          d.userInitial.isEmpty ? '—' : d.userInitial,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.initialsPartner,
          d.partnerInitial.isEmpty ? '—' : d.partnerInitial,
        );
        break;

      case AppWidgetType.partnerDistance:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerDistanceMiles,
          '${d.distanceMiles}',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerDistanceUnit,
          'mi',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerDistanceUser,
          d.userInitial.isEmpty ? '—' : d.userInitial,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerDistancePartner,
          d.partnerInitial.isEmpty ? '—' : d.partnerInitial,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerDistanceIsSharing,
          d.partnerLocationSharing ? '1' : '0',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerDistanceUpdatedAt,
          d.partnerLocationUpdatedAt?.toUtc().toIso8601String() ?? '',
        );
        break;

      case AppWidgetType.anniversary:
        final anniversary = d.anniversary;
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.anniversaryDate,
          anniversary?.toUtc().toIso8601String() ?? '',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.anniversaryDateLabel,
          anniversary == null
              ? 'Set your date in LoveLynk'
              : DateFormat('d MMMM yyyy').format(anniversary),
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.anniversaryDaysToGo,
          anniversary == null ? '0' : '${_daysToNextAnniversary(anniversary)}',
        );
        break;

      case AppWidgetType.partnerTime:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerTimeTimezone,
          d.partnerTimezone ?? '',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerTimeUtcOffsetMinutes,
          '${d.partnerUtcOffsetMinutes}',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerTimeUtcOffsetHours,
          '${(d.partnerUtcOffsetMinutes / 60).round()}',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerTimeCity,
          d.partnerCity,
        );
        break;

      case AppWidgetType.togetherCounter:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.togetherCounterSince,
          d.togetherSince?.toUtc().toIso8601String() ?? '',
        );
        break;

      case AppWidgetType.nextVisitCountdown:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.nextVisitTargetAt,
          d.nextVisit?.toUtc().toIso8601String() ?? '',
        );
        break;

      case AppWidgetType.partnerWeather:
        final weather = d.partnerWeather;
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerWeatherTemperature,
          '${weather.temperature}',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerWeatherCondition,
          weather.condition,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerWeatherCity,
          d.partnerCity,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerWeatherIconKey,
          WeatherIconMapper.nativeIconKey(
            conditionId: weather.conditionId ?? 802,
            isDay: weather.isDay,
          ),
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.partnerWeatherUpdatedAt,
          weather.updatedAt?.toUtc().toIso8601String() ?? '',
        );
        break;

      case AppWidgetType.loveCompass:
        final compass = Get.find<CompassService>();
        final bearing = compass.hasLocation.value
            ? compass.partnerBearing.value
            : d.compassBearing;
        final miles = compass.hasLocation.value
            ? compass.partnerMiles.value
            : d.compassMiles;
        final partnerLabel = d.partnerName.trim().split(' ').first;
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.loveCompassMiles,
          '$miles',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.loveCompassBearing,
          '$bearing',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.loveCompassDirection,
          _cardinalDirection(bearing),
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.loveCompassPartnerLabel,
          partnerLabel.isEmpty ? 'Partner' : partnerLabel,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.loveCompassNeedleDegrees,
          '$bearing',
        );
        break;

      case AppWidgetType.heartbeat:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.heartbeatCount,
          '${_data.heartbeatsFromPartner.value}',
        );
        break;

      case AppWidgetType.kiss:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.kissCount,
          '${_data.kissesFromPartner.value}',
        );
        break;

      case AppWidgetType.emoji:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.emojiRecent,
          _data.emojisFromPartner.take(3).join(','),
        );
        break;
    }
  }

  int _daysToNextAnniversary(DateTime anniversary) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(today.year, anniversary.month, anniversary.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, anniversary.month, anniversary.day);
    }
    return next.difference(today).inDays;
  }

  String _cardinalDirection(double deg) {
    final normalized = (deg % 360 + 360) % 360;
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((normalized + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  // ── Per-widget style ────────────────────────────────────────────────────

  Future<void> _writeStyleFor(AppWidgetType type, WidgetStyle style) async {
    final id = type.id;
    final map = style.toStorageMap();
    for (final entry in map.entries) {
      await HomeWidget.saveWidgetData<String>(
        WidgetAppGroup.styleKey(id, entry.key),
        entry.value,
      );
    }
  }

  Future<void> _refreshAllNativeWidgets() async {
    for (final kind in WidgetKind.implementedKinds) {
      await _updateNative(kind);
    }
  }

  Future<void> _refreshNativeWidget(AppWidgetType type) async {
    final kind = WidgetKind.iosKindFor(type);
    if (kind != null) await _updateNative(kind);
  }

  Future<void> _updateNative(String iosKind) async {
    try {
      await HomeWidget.updateWidget(iOSName: iosKind);
    } catch (_) {
      // Simulator / Android — ignore.
    }
  }
}
