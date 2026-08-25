/// In-app notification categories (separate from Activities feed).
enum NotificationCategory {
  relationship,
  account,
  subscription,
  system,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.at,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime at;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      category: category,
      at: at,
      isRead: isRead ?? this.isRead,
    );
  }
}
