import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/widget_data_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/interaction_models/interaction_feed_item.dart';
import '../../../data/models/widget_models/reaction_activity.dart';
import '../../../data/repositories/interaction_repository.dart';
import '../../../routes/app_pages.dart';

enum ActivityFilter { all, heartbeat, kiss, emoji }

enum ActivityKind { heartbeat, kiss, emoji }

class ActivityFeedItem {
  const ActivityFeedItem({
    required this.kind,
    required this.reaction,
  });

  final ActivityKind kind;
  final ReactionActivity reaction;

  String get headline {
    final who = reaction.senderName;
    switch (kind) {
      case ActivityKind.heartbeat:
        return reaction.isFromMe
            ? 'You sent ${reaction.count} heartbeat${reaction.count == 1 ? '' : 's'}'
            : '$who sent you ${reaction.count} heartbeat${reaction.count == 1 ? '' : 's'}';
      case ActivityKind.kiss:
        return reaction.isFromMe
            ? 'You sent ${reaction.count} kiss${reaction.count == 1 ? '' : 'es'}'
            : '$who sent you ${reaction.count} kiss${reaction.count == 1 ? '' : 'es'}';
      case ActivityKind.emoji:
        final e = reaction.emoji ?? '😊';
        return reaction.isFromMe ? 'You sent $e' : '$who sent you $e';
    }
  }

  String get kindLabel {
    switch (kind) {
      case ActivityKind.heartbeat:
        return 'Heartbeat';
      case ActivityKind.kiss:
        return 'Kiss';
      case ActivityKind.emoji:
        return 'Emoji';
    }
  }
}

class ActivitiesController extends GetxController {
  late final WidgetDataService _data;
  late final IInteractionRepository _repo;

  final filter = ActivityFilter.all.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;
  final serverItems = <ActivityFeedItem>[].obs;
  DateTime? _nextCursor;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<WidgetDataService>();
    _repo = Get.find<IInteractionRepository>();
    final initialFilter = Get.arguments?['filter'] as ActivityFilter?;
    if (initialFilter != null) {
      filter.value = initialFilter;
    }
    loadFeed(refresh: true);
  }

  String get partnerName => _data.data.value.partnerName;

  String? _filterKindParam(ActivityFilter f) {
    switch (f) {
      case ActivityFilter.heartbeat:
        return 'heartbeat';
      case ActivityFilter.kiss:
        return 'kiss';
      case ActivityFilter.emoji:
        return 'emoji';
      case ActivityFilter.all:
        return null;
    }
  }

  ActivityKind _parseKind(String raw) {
    switch (raw) {
      case 'kiss':
        return ActivityKind.kiss;
      case 'emoji':
        return ActivityKind.emoji;
      default:
        return ActivityKind.heartbeat;
    }
  }

  ActivityFeedItem _toFeedItem(InteractionFeedItem item) {
    return ActivityFeedItem(
      kind: _parseKind(item.kind),
      reaction: ReactionActivity(
        id: item.id,
        senderName: item.senderName,
        isFromMe: item.isFromMe,
        count: item.count,
        at: item.createdAt,
        emoji: item.emoji,
      ),
    );
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      isLoading.value = true;
      _nextCursor = null;
    }

    try {
      final page = await _repo.getFeed(
        kind: _filterKindParam(filter.value),
        before: _nextCursor,
        limit: 30,
      );

      final mapped = page.items.map(_toFeedItem).toList();
      if (refresh) {
        serverItems.assignAll(mapped);
      } else {
        serverItems.addAll(mapped);
      }

      hasMore.value = page.hasMore;
      _nextCursor = page.nextCursor;
    } catch (e) {
      Log.e('[ActivitiesController] loadFeed error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
    isLoadingMore.value = true;
    await loadFeed(refresh: false);
  }

  Future<void> refreshFeed() async {
    await Future.wait([
      _data.refreshFromBackend(),
      loadFeed(refresh: true),
    ]);
  }

  List<ActivityFeedItem> get allItems {
    // If server items are available, merge any unsaved/optimistic items from _data
    if (serverItems.isNotEmpty) {
      return serverItems;
    }

    // Fallback to local _data activities (e.g. today's live cache)
    final items = <ActivityFeedItem>[
      for (final r in _data.heartbeatActivity)
        ActivityFeedItem(kind: ActivityKind.heartbeat, reaction: r),
      for (final r in _data.kissActivity)
        ActivityFeedItem(kind: ActivityKind.kiss, reaction: r),
      for (final r in _data.emojiActivity)
        ActivityFeedItem(kind: ActivityKind.emoji, reaction: r),
    ]..sort((a, b) => b.reaction.at.compareTo(a.reaction.at));
    return items;
  }

  List<ActivityFeedItem> get filteredItems {
    // Touch reactive lists so Obx rebuilds when any activity changes.
    _data.heartbeatActivity.length;
    _data.kissActivity.length;
    _data.emojiActivity.length;

    final f = filter.value;
    final items = allItems;
    if (f == ActivityFilter.all) return items;
    final kind = switch (f) {
      ActivityFilter.heartbeat => ActivityKind.heartbeat,
      ActivityFilter.kiss => ActivityKind.kiss,
      ActivityFilter.emoji => ActivityKind.emoji,
      ActivityFilter.all => ActivityKind.heartbeat,
    };
    return items.where((e) => e.kind == kind).toList();
  }

  void setFilter(ActivityFilter value) {
    filter.value = value;
    loadFeed(refresh: true);
  }

  String timeLabel(DateTime at) {
    final now = DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(at);
  }

  void openSummary(ActivityKind kind) {
    switch (kind) {
      case ActivityKind.heartbeat:
        Get.toNamed(Routes.HEARTBEAT_SUMMARY);
      case ActivityKind.kiss:
        Get.toNamed(Routes.KISS_SUMMARY);
      case ActivityKind.emoji:
        Get.toNamed(Routes.EMOJI_SUMMARY);
    }
  }
}
