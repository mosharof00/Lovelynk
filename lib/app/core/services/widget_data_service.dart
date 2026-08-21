import 'dart:async';

import 'package:get/get.dart';

import '../../data/models/widget_models/reaction_activity.dart';
import '../../data/models/widget_models/widget_data.dart';

/// Central source of live widget data for the whole app.
///
/// Both the Widgets screen and (later) the Home screen read from here, so every
/// widget shows the same values. Currently seeded with [WidgetData.mock];
/// [refreshFromBackend] is the single seam where Supabase will plug in.
class WidgetDataService extends GetxService {
  /// The relationship data snapshot. Changes only when data actually changes.
  final data = WidgetData.mock().obs;

  /// Ticks every second so live counters / clocks can rebuild. Widgets read
  /// this inside a small [Obx] so only the changing text repaints.
  final now = DateTime.now().obs;

  /// Emojis the user has sent, newest first (Emoji widget).
  final sentEmojis = <String>['😍', '😘', '🥰'].obs;

  /// Heartbeats received from the partner (what the small widget shows).
  final heartbeatsFromPartner = 90.obs;

  /// Heartbeats I sent to the partner.
  final heartbeatsFromMe = 57.obs;

  /// Today's heartbeat activity (newest first).
  final heartbeatActivity = <ReactionActivity>[].obs;

  Timer? _ticker;

  WidgetDataService init() {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => now.value = DateTime.now(),
    );
    _seedHeartbeatActivity();
    return this;
  }

  void _seedHeartbeatActivity() {
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

  void sendEmoji(String emoji) {
    sentEmojis.insert(0, emoji);
    if (sentEmojis.length > 9) {
      sentEmojis.removeRange(9, sentEmojis.length);
    }
    // TODO(Supabase): push the reaction to the partner.
  }

  void sendKiss() {
    // TODO(Supabase): record + push a kiss to the partner.
  }

  /// Records one heartbeat from me → partner and bumps the feed.
  void sendHeartbeat({int count = 1}) {
    heartbeatsFromMe.value += count;
    final now = DateTime.now();
    final list = heartbeatActivity.toList();
    if (list.isNotEmpty &&
        list.first.isFromMe &&
        now.difference(list.first.at).inMinutes < 5) {
      list[0] = ReactionActivity(
        senderName: 'Me',
        isFromMe: true,
        count: list.first.count + count,
        at: now,
      );
    } else {
      list.insert(
        0,
        ReactionActivity(
          senderName: 'Me',
          isFromMe: true,
          count: count,
          at: now,
        ),
      );
    }
    heartbeatActivity.assignAll(list);
    // TODO(Supabase): insert/increment reaction row + push.
  }
}
