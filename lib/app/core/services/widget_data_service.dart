import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/widget_models/reaction_activity.dart';
import '../../data/models/user_models/session_bootstrap.dart';
import '../../data/models/widget_models/widget_data.dart';
import '../widgets/widget_sync_service.dart';
import 'session_service.dart';

/// Central source of live widget data for the whole app.
///
/// Both the Widgets screen and the Home screen read from here, so every
/// widget shows the same values. Couple data comes from [SessionService];
/// interaction counts are local until the interactions RPCs are connected.
///
/// Interactive widget cards always show **partner-side** values (what they
/// sent you). Summary screens show both sides.
class WidgetDataService extends GetxService {
  /// The relationship data snapshot, derived from [SessionService.bootstrap].
  final data = WidgetData.fromSession(null).obs;

  /// Ticks every second so live counters / clocks can rebuild. Widgets read
  /// this inside a small [Obx] so only the changing text repaints.
  final now = DateTime.now().obs;

  // ── Heartbeat ─────────────────────────────────────────────────────

  /// Heartbeats received from the partner (small widget shows this).
  final heartbeatsFromPartner = 0.obs;

  /// Heartbeats I sent to the partner.
  final heartbeatsFromMe = 0.obs;

  /// Today's heartbeat activity (newest first).
  final heartbeatActivity = <ReactionActivity>[].obs;

  // ── Kiss ──────────────────────────────────────────────────────────

  /// Kisses received from the partner (small widget shows this).
  final kissesFromPartner = 0.obs;

  /// Kisses I sent to the partner.
  final kissesFromMe = 0.obs;

  final kissActivity = <ReactionActivity>[].obs;

  // ── Emoji ─────────────────────────────────────────────────────────

  /// Recent emojis received from the partner (small widget shows these).
  final emojisFromPartner = <String>[].obs;

  /// Recent emojis I sent (summary / history only — not on the widget card).
  final emojisFromMe = <String>[].obs;

  /// Total emoji sends (header counts on summary).
  final emojiCountFromPartner = 0.obs;
  final emojiCountFromMe = 0.obs;

  final emojiActivity = <ReactionActivity>[].obs;

  Timer? _ticker;

  WidgetDataService init() {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => now.value = DateTime.now(),
    );
    _applySession(SessionService.to.bootstrap.value);
    ever<SessionBootstrap?>(SessionService.to.bootstrap, _applySession);
    return this;
  }

  String? _coupleId;

  /// Rebuilds widget data from the session. Interaction counts and history
  /// reset when the couple changes (connect / disconnect / other account);
  /// they are filled from the server once interactions are connected.
  void _applySession(SessionBootstrap? session) {
    data.value = WidgetData.fromSession(session);

    final coupleId = session?.couple?.id;
    if (coupleId != _coupleId) {
      _coupleId = coupleId;
      _resetInteractions();
    }

    if (Get.isRegistered<WidgetSyncService>()) {
      Get.find<WidgetSyncService>().syncAll();
    }
  }

  void _resetInteractions() {
    heartbeatsFromPartner.value = 0;
    heartbeatsFromMe.value = 0;
    heartbeatActivity.clear();
    kissesFromPartner.value = 0;
    kissesFromMe.value = 0;
    kissActivity.clear();
    emojisFromPartner.clear();
    emojisFromMe.clear();
    emojiCountFromPartner.value = 0;
    emojiCountFromMe.value = 0;
    emojiActivity.clear();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  /// TODO(Supabase): fetch the couple's row and subscribe to realtime changes,
  /// then `data.value = WidgetData.fromSupabase(row)`. Everything else already
  /// reacts to `data`.
  Future<void> refreshFromBackend() async {
    // Intentionally mock for now.
  }

  // ── Interactive actions ──────────────────────────────────────────

  /// Records one heartbeat from me → partner. Widget still shows partner count.
  void sendHeartbeat({int count = 1}) {
    heartbeatsFromMe.value += count;
    _bumpActivity(
      list: heartbeatActivity,
      count: count,
      now: DateTime.now(),
    );
    // TODO(Supabase): insert/increment reaction row + push.
  }

  /// Records one kiss from me → partner. Widget still shows partner count.
  void sendKiss({int count = 1}) {
    kissesFromMe.value += count;
    _bumpActivity(
      list: kissActivity,
      count: count,
      now: DateTime.now(),
    );
    // TODO(Supabase): record + push a kiss to the partner.
  }

  /// Records an emoji I sent. Widget keeps showing partner emojis only.
  void sendEmoji(String emoji) {
    emojiCountFromMe.value += 1;
    emojisFromMe.insert(0, emoji);
    if (emojisFromMe.length > 9) {
      emojisFromMe.removeRange(9, emojisFromMe.length);
    }
    final now = DateTime.now();
    final list = emojiActivity.toList();
    list.insert(
      0,
      ReactionActivity(
        senderName: 'Me',
        isFromMe: true,
        count: 1,
        emoji: emoji,
        at: now,
      ),
    );
    emojiActivity.assignAll(list);
    // TODO(Supabase): push the reaction to the partner.
  }

  void _bumpActivity({
    required RxList<ReactionActivity> list,
    required int count,
    required DateTime now,
    String? emoji,
  }) {
    final items = list.toList();
    if (items.isNotEmpty &&
        items.first.isFromMe &&
        emoji == null &&
        now.difference(items.first.at).inMinutes < 5) {
      items[0] = ReactionActivity(
        senderName: 'Me',
        isFromMe: true,
        count: items.first.count + count,
        at: now,
        emoji: emoji,
      );
    } else {
      items.insert(
        0,
        ReactionActivity(
          senderName: 'Me',
          isFromMe: true,
          count: count,
          at: now,
          emoji: emoji,
        ),
      );
    }
    list.assignAll(items);
  }
}
