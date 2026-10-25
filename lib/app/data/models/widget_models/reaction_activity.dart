/// One batched reaction in the Heartbeat / Kiss / Emoji activity feed.
class ReactionActivity {
  const ReactionActivity({
    this.id,
    required this.senderName,
    required this.isFromMe,
    required this.count,
    required this.at,
    this.emoji,
  });

  final int? id;
  final String senderName;
  final bool isFromMe;
  final int count;
  final DateTime at;

  /// Set for emoji reactions (e.g. "😍"); null for heartbeat / kiss.
  final String? emoji;

  factory ReactionActivity.fromJson(Map<String, dynamic> json) {
    DateTime parseDate() {
      final raw = json['at'] ?? json['created_at'];
      if (raw is String) {
        return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ReactionActivity(
      id: (json['id'] as num?)?.toInt(),
      senderName: json['sender_name'] as String? ??
          (json['is_from_me'] == true ? 'Me' : 'Partner'),
      isFromMe: json['is_from_me'] as bool? ?? false,
      count: (json['count'] as num?)?.toInt() ?? 1,
      at: parseDate(),
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'sender_name': senderName,
    'is_from_me': isFromMe,
    'count': count,
    'at': at.toIso8601String(),
    if (emoji != null) 'emoji': emoji,
  };
}
