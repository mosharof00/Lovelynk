/// Supabase RPC function names (`supabase.rpc(...)`).
/// Each maps to a `public.<name>` wrapper in `supabase/migrations/`.
class SupabaseRpc {
  SupabaseRpc._();

  static const getSessionBootstrap = 'get_session_bootstrap';
  static const getMyAccess = 'get_my_access';
  static const touchSession = 'touch_session';
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
