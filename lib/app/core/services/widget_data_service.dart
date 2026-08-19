import 'dart:async';

import 'package:get/get.dart';

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

  Timer? _ticker;

  WidgetDataService init() {
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => now.value = DateTime.now(),
    );
    return this;
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

  void sendHeartbeat() {
    // TODO(Supabase): record + push a heartbeat to the partner.
  }
}
