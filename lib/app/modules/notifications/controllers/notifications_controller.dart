import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/notification_models/app_notification.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../routes/app_pages.dart';

class NotificationsController extends GetxController {
  final INotificationRepository _repo = Get.find<INotificationRepository>();

  final items = <AppNotification>[].obs;
  final isLoading = false.obs;

  int get unreadCount => items.where((e) => !e.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final list = await _repo.getNotifications(limit: 50);
      items.assignAll(list);
      if (Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.refreshUnreadCount();
      }
    } catch (e) {
      Log.w('Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    try {
      final list = await _repo.getNotifications(limit: 50);
      items.assignAll(list);
      if (Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.refreshUnreadCount();
      }
    } catch (e) {
      Log.w('Failed to refresh notifications: $e');
    }
  }

  Future<void> markRead(String id) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx < 0 || items[idx].isRead) return;

    items[idx] = items[idx].copyWith(isRead: true);
    try {
      await _repo.markRead([id]);
      if (Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.refreshUnreadCount();
      }
    } catch (e) {
      Log.w('Failed to mark notification read: $e');
    }
  }

  Future<void> markAllRead() async {
    if (items.isEmpty || unreadCount == 0) return;

    items.assignAll(items.map((e) => e.copyWith(isRead: true)));
    if (Get.isRegistered<PushNotificationService>()) {
      PushNotificationService.to.unreadCount.value = 0;
    }

    try {
      await _repo.markAllRead();
      if (Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.refreshUnreadCount();
      }
    } catch (e) {
      Log.w('Failed to mark all notifications read: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    final idx = items.indexWhere((e) => e.id == id);
    if (idx < 0) return;

    final removed = items.removeAt(idx);
    try {
      await _repo.deleteNotification(id);
      if (Get.isRegistered<PushNotificationService>()) {
        PushNotificationService.to.refreshUnreadCount();
      }
    } catch (e) {
      Log.w('Failed to delete notification: $e');
      items.insert(idx, removed);
    }
  }

  void onTapNotification(AppNotification n) {
    if (!n.isRead) {
      markRead(n.id);
    }

    final route = n.route;
    if (route != null && route.isNotEmpty && route != Routes.NOTIFICATIONS) {
      try {
        Get.toNamed(route);
      } catch (e) {
        Log.w('Deep link to $route failed: $e');
      }
    }
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

  String categoryLabel(NotificationCategory c) => c.label;
}
