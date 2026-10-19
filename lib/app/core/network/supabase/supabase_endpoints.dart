/// Supabase RPC function names (`supabase.rpc(...)`).
/// Each maps to a `public.<name>` wrapper in `supabase/migrations/`.
class SupabaseRpc {
  SupabaseRpc._();

  static const getSessionBootstrap = 'get_session_bootstrap';
  static const getMyAccess = 'get_my_access';
  static const touchSession = 'touch_session';

  // Pairing
  static const getMyInvite = 'get_my_invite';
  static const createInvite = 'create_invite';
  static const cancelInvite = 'cancel_invite';
  static const acceptInvite = 'accept_invite';
  static const leaveCouple = 'leave_couple';
  static const updateCouple = 'update_couple';
  static const updatePartnerNickname = 'update_partner_nickname';

  // Profile & support
  static const updateMyProfile = 'update_my_profile';
  static const submitSupportTicket = 'submit_support_ticket';

  // Location & partner snapshot
  static const updateMyLocation = 'update_my_location';
  static const setLocationSharing = 'set_location_sharing';
  static const getPartnerSnapshot = 'get_partner_snapshot';

  // Push notifications & notification center
  static const registerPushDevice = 'register_push_device';
  static const unregisterPushDevice = 'unregister_push_device';
  static const unreadNotificationCount = 'unread_notification_count';
  static const markNotificationsRead = 'mark_notifications_read';
  static const markAllNotificationsRead = 'mark_all_notifications_read';
  static const deleteNotification = 'delete_notification';
  static const getNotificationPreferences = 'get_notification_preferences';
  static const updateNotificationPreferences = 'update_notification_preferences';
}

/// Edge Function names (`supabase.functions.invoke(...)`).
class SupabaseFunction {
  SupabaseFunction._();

  static const deleteAccount = 'delete-account';
  static const refreshWeather = 'refresh-weather';
  static const pushDispatch = 'push-dispatch';
}

/// Realtime Broadcast on the private `user:{id}` channel.
class SupabaseRealtime {
  SupabaseRealtime._();

  static String userTopic(String userId) => 'user:$userId';

  static const couplePaired = 'couple.paired';
  static const coupleLeft = 'couple.left';

  /// Partner changed their profile or shared couple data.
  static const coupleUpdated = 'couple.updated';

  /// Partner location changed.
  static const partnerLocation = 'partner.location';

  /// Partner weather refreshed.
  static const partnerWeather = 'partner.weather';

  /// New in-app notification arrived.
  static const notificationNew = 'notification.new';
}

/// Supabase table / view names (`supabase.from(...)`).
class SupabaseTable {
  SupabaseTable._();

  static const users = 'users';
  static const appSettings = 'app_settings';
  static const notifications = 'notifications';
  static const notificationPreferences = 'notification_preferences';
  static const pushDevices = 'push_devices';
}

/// Supabase Storage bucket ids.
class SupabaseBucket {
  SupabaseBucket._();

  static const avatars = 'avatars';
  static const supportAttachments = 'support-attachments';
  static const publicAssets = 'public-assets';
}
