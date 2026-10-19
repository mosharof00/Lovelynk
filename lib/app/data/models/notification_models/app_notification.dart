/// In-app and push notification categories.
enum NotificationCategory {
  heartbeat('Heartbeat'),
  kiss('Kiss'),
  emoji('Emoji Reaction'),
  relationship('Relationship'),
  subscription('Subscription'),
  system('System'),
  account('Account'),
  announcement('Announcement');

  const NotificationCategory(this.label);
  final String label;

  static NotificationCategory fromString(String? val) {
    if (val == null) return NotificationCategory.relationship;
    return NotificationCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => NotificationCategory.relationship,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.at,
    this.userId,
    this.readAt,
    this.data,
    this.isRead = false,
  });

  final String id;
  final String? userId;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime at;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final bool isRead;

  String? get route => data?['route'] as String?;

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationCategory? category,
    DateTime? at,
    DateTime? readAt,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      at: at ?? this.at,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final readAtStr = json['read_at'] as String?;
    final readAt = readAtStr != null ? DateTime.tryParse(readAtStr)?.toLocal() : null;
    final createdAtStr = json['created_at'] as String?;
    final at = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now())
        : DateTime.now();

    return AppNotification(
      id: (json['id'] ?? '').toString(),
      userId: json['user_id']?.toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      category: NotificationCategory.fromString(json['category'] as String?),
      at: at,
      readAt: readAt,
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      isRead: readAt != null || json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'body': body,
      'category': category.name,
      'created_at': at.toIso8601String(),
      if (readAt != null) 'read_at': readAt?.toIso8601String(),
      if (data != null) 'data': data,
      'is_read': isRead,
    };
  }
}

/// User's notification preferences from `notification_preferences` table.
class NotificationPreferences {
  const NotificationPreferences({
    this.pushHeartbeat = true,
    this.pushKiss = true,
    this.pushEmoji = true,
    this.pushRelationship = true,
    this.pushSubscription = true,
    this.pushAnnouncements = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool pushHeartbeat;
  final bool pushKiss;
  final bool pushEmoji;
  final bool pushRelationship;
  final bool pushSubscription;
  final bool pushAnnouncements;
  final String? quietHoursStart; // Format: "HH:mm" (24h)
  final String? quietHoursEnd;   // Format: "HH:mm" (24h)

  bool get hasQuietHours =>
      quietHoursStart != null &&
      quietHoursEnd != null &&
      quietHoursStart!.isNotEmpty &&
      quietHoursEnd!.isNotEmpty;

  NotificationPreferences copyWith({
    bool? pushHeartbeat,
    bool? pushKiss,
    bool? pushEmoji,
    bool? pushRelationship,
    bool? pushSubscription,
    bool? pushAnnouncements,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool clearQuietHours = false,
  }) {
    return NotificationPreferences(
      pushHeartbeat: pushHeartbeat ?? this.pushHeartbeat,
      pushKiss: pushKiss ?? this.pushKiss,
      pushEmoji: pushEmoji ?? this.pushEmoji,
      pushRelationship: pushRelationship ?? this.pushRelationship,
      pushSubscription: pushSubscription ?? this.pushSubscription,
      pushAnnouncements: pushAnnouncements ?? this.pushAnnouncements,
      quietHoursStart: clearQuietHours ? null : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd: clearQuietHours ? null : (quietHoursEnd ?? this.quietHoursEnd),
    );
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushHeartbeat: json['push_heartbeat'] as bool? ?? true,
      pushKiss: json['push_kiss'] as bool? ?? true,
      pushEmoji: json['push_emoji'] as bool? ?? true,
      pushRelationship: json['push_relationship'] as bool? ?? true,
      pushSubscription: json['push_subscription'] as bool? ?? true,
      pushAnnouncements: json['push_announcements'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_heartbeat': pushHeartbeat,
      'push_kiss': pushKiss,
      'push_emoji': pushEmoji,
      'push_relationship': pushRelationship,
      'push_subscription': pushSubscription,
      'push_announcements': pushAnnouncements,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }
}
