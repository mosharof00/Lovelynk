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
}

/// Realtime Broadcast on the private `user:{id}` channel.
class SupabaseRealtime {
  SupabaseRealtime._();

  static String userTopic(String userId) => 'user:$userId';

  static const couplePaired = 'couple.paired';
  static const coupleLeft = 'couple.left';
}

/// Supabase table / view names (`supabase.from(...)`).
class SupabaseTable {
  SupabaseTable._();

  static const users = 'users';
  static const appSettings = 'app_settings';
}

/// Supabase Storage bucket ids.
class SupabaseBucket {
  SupabaseBucket._();

  static const avatars = 'avatars';
  static const supportAttachments = 'support-attachments';
  static const publicAssets = 'public-assets';
}
