/// Cursor paginated interaction feed item returned by `get_interaction_feed`.
class InteractionFeedItem {
  final int id;
  final String kind; // 'heartbeat' | 'kiss' | 'emoji'
  final int count;
  final String? emoji;
  final String senderId;
  final String recipientId;
  final bool isFromMe;
  final String senderName;
  final DateTime createdAt;

  const InteractionFeedItem({
    required this.id,
    required this.kind,
    required this.count,
    this.emoji,
    required this.senderId,
    required this.recipientId,
    required this.isFromMe,
    required this.senderName,
    required this.createdAt,
  });

  factory InteractionFeedItem.fromJson(Map<String, dynamic> json) {
    return InteractionFeedItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? 'heartbeat',
      count: (json['count'] as num?)?.toInt() ?? 1,
      emoji: json['emoji'] as String?,
      senderId: json['sender_id'] as String? ?? '',
      recipientId: json['recipient_id'] as String? ?? '',
      isFromMe: json['is_from_me'] as bool? ?? false,
      senderName: json['sender_name'] as String? ??
          (json['is_from_me'] == true ? 'Me' : 'Partner'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)?.toLocal() ??
              DateTime.now()
          : DateTime.now(),
    );
  }

  String get headline {
    switch (kind) {
      case 'heartbeat':
        return isFromMe
            ? 'You sent $count heartbeat${count == 1 ? '' : 's'}'
            : '$senderName sent you $count heartbeat${count == 1 ? '' : 's'}';
      case 'kiss':
        return isFromMe
            ? 'You sent $count kiss${count == 1 ? '' : 'es'}'
            : '$senderName sent you $count kiss${count == 1 ? '' : 'es'}';
      case 'emoji':
        final e = emoji ?? '😊';
        return isFromMe ? 'You sent $e' : '$senderName sent you $e';
      default:
        return '$senderName sent an interaction';
    }
  }

  String get kindLabel {
    switch (kind) {
      case 'heartbeat':
        return 'Heartbeat';
      case 'kiss':
        return 'Kiss';
      case 'emoji':
        return 'Emoji';
      default:
        return 'Activity';
    }
  }
}

/// Paginated result from `get_interaction_feed`.
class InteractionFeedPage {
  final List<InteractionFeedItem> items;
  final bool hasMore;
  final DateTime? nextCursor;

  const InteractionFeedPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  factory InteractionFeedPage.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List?)
            ?.map((e) =>
                InteractionFeedItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        <InteractionFeedItem>[];

    DateTime? next;
    if (json['next_cursor'] != null) {
      next = DateTime.tryParse(json['next_cursor'] as String)?.toLocal();
    }

    return InteractionFeedPage(
      items: list,
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: next,
    );
  }
}
