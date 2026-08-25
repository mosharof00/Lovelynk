import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/widget_models/reaction_activity.dart';
import '../../data/models/widget_models/widget_data.dart';

/// Central source of live widget data for the whole app.
///
/// Both the Widgets screen and (later) the Home screen read from here, so every
/// widget shows the same values. Currently seeded with [WidgetData.mock];
/// [refreshFromBackend] is the single seam where Supabase will plug in.
///
/// Interactive widget cards always show **partner-side** values (what they
/// sent you). Summary screens show both sides.
class WidgetDataService extends GetxService {
  /// The relationship data snapshot. Changes only when data actually changes.
  final data = WidgetData.mock().obs;

  /// Ticks every second so live counters / clocks can rebuild. Widgets read
  /// this inside a small [Obx] so only the changing text repaints.
  final now = DateTime.now().obs;

  // ── Heartbeat ─────────────────────────────────────────────────────

  /// Heartbeats received from the partner (small widget shows this).
  final heartbeatsFromPartner = 90.obs;

  /// Heartbeats I sent to the partner.
  final heartbeatsFromMe = 57.obs;

  /// Today's heartbeat activity (newest first).
  final heartbeatActivity = <ReactionActivity>[].obs;

  // ── Kiss ──────────────────────────────────────────────────────────

  /// Kisses received from the partner (small widget shows this).
  final kissesFromPartner = 42.obs;

  /// Kisses I sent to the partner.
  final kissesFromMe = 28.obs;

  final kissActivity = <ReactionActivity>[].obs;

  // ── Emoji ─────────────────────────────────────────────────────────

  /// Recent emojis received from the partner (small widget shows these).
  final emojisFromPartner = <String>['😍', '😘', '🥰'].obs;

  /// Recent emojis I sent (summary / history only — not on the widget card).
  final emojisFromMe = <String>['🔥', '😂', '😊'].obs;

  /// Total emoji sends (header counts on summary).
  final emojiCountFromPartner = 36.obs;
  final emojiCountFromMe = 19.obs;

  final emojiActivity = <ReactionActivity>[].obs;

  Timer? _ticker;

  WidgetDataService init() {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => now.value = DateTime.now(),
    );
    _seedActivities();
    return this;
  }

  void _seedActivities() {
    final now = DateTime.now();
    final partner = data.value.partnerName;

    heartbeatActivity.assignAll([
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 5,
        at: now.subtract(const Duration(minutes: 12)),
      ),
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 7,
        at: now.subtract(const Duration(minutes: 48)),
      ),
      ReactionActivity(
        senderName: 'Me',
        isFromMe: true,
        count: 3,
        at: now.subtract(const Duration(hours: 1, minutes: 20)),
      ),
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 53,
        at: now.subtract(const Duration(hours: 2, minutes: 5)),
      ),
    ]);

    kissActivity.assignAll([
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 3,
        at: now.subtract(const Duration(minutes: 20)),
      ),
      ReactionActivity(
        senderName: 'Me',
        isFromMe: true,
        count: 2,
        at: now.subtract(const Duration(minutes: 55)),
      ),
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 8,
        at: now.subtract(const Duration(hours: 1, minutes: 40)),
      ),
    ]);

    emojiActivity.assignAll([
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 1,
        emoji: '😍',
        at: now.subtract(const Duration(minutes: 8)),
      ),
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 1,
        emoji: '😘',
        at: now.subtract(const Duration(minutes: 35)),
      ),
      ReactionActivity(
        senderName: 'Me',
        isFromMe: true,
        count: 1,
        emoji: '🔥',
        at: now.subtract(const Duration(hours: 1)),
      ),
      ReactionActivity(
        senderName: partner,
        isFromMe: false,
        count: 1,
        emoji: '🥰',
        at: now.subtract(const Duration(hours: 2, minutes: 15)),
      ),
    ]);
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
