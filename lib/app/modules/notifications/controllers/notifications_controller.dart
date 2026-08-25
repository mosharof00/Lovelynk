import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/notification_models/app_notification.dart';

class NotificationsController extends GetxController {
  final items = <AppNotification>[].obs;

  int get unreadCount => items.where((e) => !e.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    items.assignAll([
      AppNotification(
        id: '1',
        title: 'Next visit updated',
        body: 'Milla changed your next visit date to Oct 12.',
        category: NotificationCategory.relationship,
        at: now.subtract(const Duration(minutes: 18)),
      ),
      AppNotification(
        id: '2',
        title: 'Anniversary reminder',
        body: 'Your anniversary is in 12 days. Plan something special!',
        category: NotificationCategory.relationship,
        at: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: '3',
        title: 'Subscription renews soon',
        body: 'Your Lovelynk Plus plan renews in 3 days.',
        category: NotificationCategory.subscription,
        at: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'Setup guide shared',
        body: 'You asked Milla to add the Heartbeat widget.',
        category: NotificationCategory.relationship,
        at: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: '5',
        title: 'Welcome to Lovelynk',
        body: 'Finish connecting with your partner to unlock all widgets.',
        category: NotificationCategory.account,
        at: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: '6',
        title: 'Privacy update',
        body: 'We’ve updated our Privacy Policy. Tap to review.',
        category: NotificationCategory.system,
        at: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
    ]);
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

  String categoryLabel(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.relationship:
        return 'Relationship';
      case NotificationCategory.account:
        return 'Account';
      case NotificationCategory.subscription:
        return 'Subscription';
      case NotificationCategory.system:
        return 'System';
    }
  }

  void markRead(String id) {
    final i = items.indexWhere((e) => e.id == id);
    if (i < 0 || items[i].isRead) return;
    items[i] = items[i].copyWith(isRead: true);
  }

  void markAllRead() {
    items.assignAll(items.map((e) => e.copyWith(isRead: true)));
  }

  void onTapNotification(AppNotification n) {
    markRead(n.id);
    // TODO(Supabase): deep-link by category / payload.
  }
}
