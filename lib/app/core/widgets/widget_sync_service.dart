import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/widget_models/app_widget_type.dart';
import '../../data/models/widget_models/widget_style.dart';
import '../services/subscription_service.dart';
import '../services/widget_data_service.dart';
import 'widget_app_group.dart';
import '../widgets/widget_style_store.dart';
import 'widget_kind.dart';

/// Central bridge between Flutter and native WidgetKit via the App Group.
///
/// Responsibilities:
/// - Write widget **data** (from [WidgetDataService] / future Supabase)
/// - Write widget **styles** (from customise screen)
/// - Write global **lock** state (subscription)
/// - Trigger native timeline reloads (`HomeWidget.updateWidget`)
/// - [applyPushPayload] — entry point when a push notification arrives (later)
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

  /// Called on every cold start. Later: fetch Supabase first, then sync.
  Future<void> syncOnAppLaunch() async {
    await _data.refreshFromBackend();
    await syncAll();
  }

  /// Full sync — call after login, partner connect, or manual refresh.
  Future<void> syncAll() async {
    await _writeGlobalLock();
    for (final type in AppWidgetType.values) {
      await _writeDataFor(type);
      if (WidgetKind.hasNativeImplementation(type) &&
          Get.isRegistered<WidgetStyleStore>()) {
        final styleStore = Get.find<WidgetStyleStore>();
        final style = await styleStore.load(type);
        await _writeStyleFor(type, style);
      }
    }
    await _refreshAllNativeWidgets();
  }

  /// Sync one widget's data + refresh its native timeline.
  Future<void> syncWidget(AppWidgetType type) async {
    await _writeGlobalLock();
    await _writeDataFor(type);
    await _refreshNativeWidget(type);
  }

  /// After customise save — rewrite style keys and refresh native widget.
  Future<void> syncStyle(AppWidgetType type, WidgetStyle style) async {
    await _writeStyleFor(type, style);
    await _refreshNativeWidget(type);
  }

  /// Push notification handler (Phase: backend). Parses payload and refreshes.
  Future<void> applyPushPayload(Map<String, dynamic> payload) async {
    // TODO(Supabase/APNs): map payload → update WidgetDataService, then:
  // await syncAll();
    final typeId = payload['widget_type'] as String?;
    if (typeId != null) {
      final type = AppWidgetTypeX.fromId(typeId);
      if (type != null) {
        await syncWidget(type);
        return;
      }
    }
    await syncAll();
  }

  // ── Global lock ─────────────────────────────────────────────────────────

  Future<void> _writeGlobalLock() async {
    final locked = !_subscription.isWidgetsUnlocked;
    await HomeWidget.saveWidgetData<String>(
      WidgetAppGroup.globalLocked,
      locked ? '1' : '0',
    );
    if (locked) {
      await HomeWidget.saveWidgetData<String>(
        WidgetAppGroup.globalLockMessage,
        _subscription.widgetLockMessage ?? 'Locked',
      );
    }
  }

  // ── Per-widget data ─────────────────────────────────────────────────────

  Future<void> _writeDataFor(AppWidgetType type) async {
    final d = _data.data.value;
    switch (type) {
      case AppWidgetType.daysTogether:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.daysTogetherCount,
          '${d.daysTogether}',
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.daysTogetherTitle,
          'Days Together',
        );
        break;
      case AppWidgetType.initials:
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.initialsUser,
          d.userInitial,
        );
        await HomeWidget.saveWidgetData<String>(
          WidgetAppGroup.initialsPartner,
          d.partnerInitial,
        );
        break;
      default:
        // Native widgets not yet implemented — no-op until Tier 2+.
        break;
    }
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
