import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/widget_data_service.dart';
import '../../../data/models/widget_models/reaction_activity.dart';
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

  final filter = ActivityFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<WidgetDataService>();
  }

  String get partnerName => _data.data.value.partnerName;

  List<ActivityFeedItem> get allItems {
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

  void setFilter(ActivityFilter value) => filter.value = value;

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
