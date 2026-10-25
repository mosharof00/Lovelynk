import '../../core/network/supabase/supabase_endpoints.dart';
import '../../core/network/supabase/supabase_service.dart';
import '../models/notification_models/app_notification.dart';

abstract class INotificationRepository {
  Future<List<AppNotification>> getNotifications({int limit = 50, int offset = 0});

  Future<int> getUnreadCount();

  Future<int> markRead(List<String> ids);

  Future<int> markAllRead();

  Future<bool> deleteNotification(String id);

  Future<NotificationPreferences> getPreferences();

  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences prefs, {
    bool clearQuietHours = false,
  });

  Future<void> registerPushDevice({
    required String fcmToken,
    required String platform,
    String? appVersion,
  });

  Future<void> unregisterPushDevice(String fcmToken);
}

class NotificationRepository implements INotificationRepository {
  final SupabaseService _supabase;

  NotificationRepository(this._supabase);

  @override
  Future<List<AppNotification>> getNotifications({int limit = 50, int offset = 0}) {
    return _supabase.handleRequest(
      () => _supabase.client
          .from(SupabaseTable.notifications)
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1),
      (dynamic data) {
        if (data is! List) return <AppNotification>[];
        return data
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      },
      'notifications.list',
    );
  }

  @override
  Future<int> getUnreadCount() {
    return _supabase.rpc<int>(
      SupabaseRpc.unreadNotificationCount,
      mapper: (dynamic data) => (data as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<int> markRead(List<String> ids) {
    if (ids.isEmpty) return Future.value(0);
    return _supabase.rpc<int>(
      SupabaseRpc.markNotificationsRead,
      params: {'p_ids': ids},
      mapper: (dynamic data) => (data as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<int> markAllRead() {
    return _supabase.rpc<int>(
      SupabaseRpc.markAllNotificationsRead,
      mapper: (dynamic data) => (data as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<bool> deleteNotification(String id) {
    return _supabase.rpc<bool>(
      SupabaseRpc.deleteNotification,
      params: {'p_id': id},
      mapper: (dynamic data) => data == true,
    );
  }

  @override
  Future<NotificationPreferences> getPreferences() {
    return _supabase.rpc<NotificationPreferences>(
      SupabaseRpc.getNotificationPreferences,
      mapper: (dynamic data) => NotificationPreferences.fromJson(
        Map<String, dynamic>.from(data as Map),
      ),
    );
  }

  @override
  Future<NotificationPreferences> updatePreferences(
    NotificationPreferences prefs, {
    bool clearQuietHours = false,
  }) {
    return _supabase.rpc<NotificationPreferences>(
      SupabaseRpc.updateNotificationPreferences,
      params: {
        'p_push_heartbeat': prefs.pushHeartbeat,
        'p_push_kiss': prefs.pushKiss,
        'p_push_emoji': prefs.pushEmoji,
        'p_push_relationship': prefs.pushRelationship,
        'p_push_subscription': prefs.pushSubscription,
        'p_push_announcements': prefs.pushAnnouncements,
        'p_quiet_hours_start': prefs.quietHoursStart,
        'p_quiet_hours_end': prefs.quietHoursEnd,
        'p_clear_quiet_hours': clearQuietHours,
      },
      mapper: (dynamic data) => NotificationPreferences.fromJson(
        Map<String, dynamic>.from(data as Map),
      ),
    );
  }

  @override
  Future<void> registerPushDevice({
    required String fcmToken,
    required String platform,
    String? appVersion,
  }) {
    return _supabase.rpc<void>(
      SupabaseRpc.registerPushDevice,
      params: {
        'p_fcm_token': fcmToken,
        'p_platform': platform,
        'p_app_version': appVersion,
      },
      mapper: (_) {},
    );
  }

  @override
  Future<void> unregisterPushDevice(String fcmToken) {
    return _supabase.rpc<void>(
      SupabaseRpc.unregisterPushDevice,
      params: {'p_fcm_token': fcmToken},
      mapper: (_) {},
    );
  }
}
