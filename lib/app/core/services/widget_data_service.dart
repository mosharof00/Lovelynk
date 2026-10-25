import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user_models/session_bootstrap.dart';
import '../../data/models/widget_models/reaction_activity.dart';
import '../../data/models/widget_models/widget_data.dart';
import '../../data/repositories/interaction_repository.dart';
import '../theme/app_color.dart';
import '../utils/logger.dart';
import '../widgets/widget_sync_service.dart';
import 'session_service.dart';

/// Central source of live widget data for the whole app.
///
/// Both the Widgets screen and the Home screen read from here, so every
/// widget shows the same values. Couple data comes from [SessionService];
/// interaction counts are backed by [IInteractionRepository] RPCs.
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
  Timer? _heartbeatDebounceTimer;
  int _pendingHeartbeats = 0;

  Timer? _kissDebounceTimer;
  int _pendingKisses = 0;

  IInteractionRepository get _interactionRepo =>
      Get.find<IInteractionRepository>();

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
      if (coupleId != null) {
        refreshFromBackend();
      }
    }

    _syncWidgets();
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
    _pendingHeartbeats = 0;
    _pendingKisses = 0;
    _heartbeatDebounceTimer?.cancel();
    _kissDebounceTimer?.cancel();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _heartbeatDebounceTimer?.cancel();
    _kissDebounceTimer?.cancel();
    super.onClose();
  }

  /// Fetches running totals, recent emojis, and today's activity from Supabase.
  Future<void> refreshFromBackend() async {
    if (!SessionService.to.isPaired) return;
    try {
      final summary = await _interactionRepo.getSummary();
      heartbeatsFromPartner.value = summary.heartbeatsFromPartner;
      heartbeatsFromMe.value = summary.heartbeatsFromMe;
      kissesFromPartner.value = summary.kissesFromPartner;
      kissesFromMe.value = summary.kissesFromMe;
      emojiCountFromPartner.value = summary.emojiCountFromPartner;
      emojiCountFromMe.value = summary.emojiCountFromMe;
      emojisFromPartner.assignAll(summary.partnerRecentEmojis);
      emojisFromMe.assignAll(summary.myRecentEmojis);
      heartbeatActivity.assignAll(summary.todayHeartbeatActivity);
      kissActivity.assignAll(summary.todayKissActivity);
      emojiActivity.assignAll(summary.todayEmojiActivity);
      _syncWidgets();
    } catch (e) {
      Log.e('[WidgetDataService] refreshFromBackend error: $e');
    }
  }

  // ── Interactive actions ──────────────────────────────────────────

  /// Records heartbeat from me → partner with optimistic UI update and 550ms debounce.
  void sendHeartbeat({int count = 1}) {
    heartbeatsFromMe.value += count;
    _bumpActivity(
      list: heartbeatActivity,
      count: count,
      now: DateTime.now(),
      isFromMe: true,
      senderName: 'Me',
    );
    _syncWidgets();

    _pendingHeartbeats += count;
    _heartbeatDebounceTimer?.cancel();
    _heartbeatDebounceTimer = Timer(
      const Duration(milliseconds: 550),
      _flushHeartbeats,
    );
  }

  void _flushHeartbeats() async {
    if (_pendingHeartbeats <= 0) return;
    final toSend = _pendingHeartbeats;
    _pendingHeartbeats = 0;

    try {
      await _interactionRepo.sendInteraction(
        kind: 'heartbeat',
        count: toSend,
      );
    } catch (e) {
      Log.e('[WidgetDataService] Failed to send heartbeat: $e');
    }
  }

  /// Records kiss from me → partner with optimistic UI update and 550ms debounce.
  void sendKiss({int count = 1}) {
    kissesFromMe.value += count;
    _bumpActivity(
      list: kissActivity,
      count: count,
      now: DateTime.now(),
      isFromMe: true,
      senderName: 'Me',
    );
    _syncWidgets();

    _pendingKisses += count;
    _kissDebounceTimer?.cancel();
    _kissDebounceTimer = Timer(
      const Duration(milliseconds: 550),
      _flushKisses,
    );
  }

  void _flushKisses() async {
    if (_pendingKisses <= 0) return;
    final toSend = _pendingKisses;
    _pendingKisses = 0;

    try {
      await _interactionRepo.sendInteraction(
        kind: 'kiss',
        count: toSend,
      );
    } catch (e) {
      Log.e('[WidgetDataService] Failed to send kiss: $e');
    }
  }

  /// Records an emoji I sent with optimistic UI and immediate RPC.
  void sendEmoji(String emoji) {
    emojiCountFromMe.value += 1;
    emojisFromMe.remove(emoji);
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
    _syncWidgets();

    _interactionRepo
        .sendInteraction(kind: 'emoji', emoji: emoji, count: 1)
        .catchError((e) {
      Log.e('[WidgetDataService] Failed to send emoji: $e');
      return <String, dynamic>{};
    });
  }

  /// Handles incoming `interaction.new` broadcast event from partner.
  void handleIncomingInteraction(Map<String, dynamic> payload) {
    final kind = payload['kind'] as String?;
    final count = (payload['count'] as num?)?.toInt() ?? 1;
    final emoji = payload['emoji'] as String?;
    final senderName =
        payload['sender_name'] as String? ?? data.value.partnerName;
    final at = payload['created_at'] != null
        ? DateTime.tryParse(payload['created_at'] as String)?.toLocal() ??
            DateTime.now()
        : DateTime.now();

    String bannerTitle = '';
    String bannerMessage = '';

    if (kind == 'heartbeat') {
      heartbeatsFromPartner.value += count;
      _bumpActivity(
        list: heartbeatActivity,
        count: count,
        now: at,
        isFromMe: false,
        senderName: senderName,
      );
      bannerTitle = 'Heartbeat ❤️';
      bannerMessage = count == 1
          ? '$senderName sent you a heartbeat ❤️'
          : '$senderName sent you $count heartbeats ❤️';
    } else if (kind == 'kiss') {
      kissesFromPartner.value += count;
      _bumpActivity(
        list: kissActivity,
        count: count,
        now: at,
        isFromMe: false,
        senderName: senderName,
      );
      bannerTitle = 'Kiss 💋';
      bannerMessage = count == 1
          ? '$senderName sent you a kiss 💋'
          : '$senderName sent you $count kisses 💋';
    } else if (kind == 'emoji' && emoji != null) {
      emojiCountFromPartner.value += 1;
      emojisFromPartner.remove(emoji);
      emojisFromPartner.insert(0, emoji);
      if (emojisFromPartner.length > 9) {
        emojisFromPartner.removeRange(9, emojisFromPartner.length);
      }
      final list = emojiActivity.toList();
      list.insert(
        0,
        ReactionActivity(
          senderName: senderName,
          isFromMe: false,
          count: 1,
          emoji: emoji,
          at: at,
        ),
      );
      emojiActivity.assignAll(list);
      bannerTitle = 'Emoji $emoji';
      bannerMessage = '$senderName sent you $emoji';
    }

    _syncWidgets();

    // Show in-app banner for recipient if app is in foreground
    if (bannerMessage.isNotEmpty && Get.context != null) {
      Get.snackbar(
        bannerTitle,
        bannerMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColor.primaryLight.withValues(alpha: 0.95),
        colorText: AppColor.textPrimary,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 300),
        icon: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(
            kind == 'heartbeat'
                ? Icons.favorite_rounded
                : (kind == 'kiss'
                    ? Icons.favorite_border_rounded
                    : Icons.emoji_emotions_rounded),
            color: AppColor.primary,
            size: 26,
          ),
        ),
      );
    }
  }

  void _syncWidgets() {
    if (Get.isRegistered<WidgetSyncService>()) {
      Get.find<WidgetSyncService>().syncAll();
    }
  }

  void _bumpActivity({
    required RxList<ReactionActivity> list,
    required int count,
    required DateTime now,
    String? emoji,
    bool isFromMe = true,
    String senderName = 'Me',
  }) {
    final items = list.toList();
    if (items.isNotEmpty &&
        items.first.isFromMe == isFromMe &&
        emoji == null &&
        now.difference(items.first.at).inMinutes < 5) {
      items[0] = ReactionActivity(
        id: items.first.id,
        senderName: senderName,
        isFromMe: isFromMe,
        count: items.first.count + count,
        at: now,
        emoji: emoji,
      );
    } else {
      items.insert(
        0,
        ReactionActivity(
          senderName: senderName,
          isFromMe: isFromMe,
          count: count,
          at: now,
          emoji: emoji,
        ),
      );
    }
    list.assignAll(items);
  }
}
