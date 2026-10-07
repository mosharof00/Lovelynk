import '../../core/network/supabase/supabase_endpoints.dart';
import '../../core/network/supabase/supabase_service.dart';
import '../models/user_models/session_bootstrap.dart';

abstract class IUserRepository {
  Future<SessionBootstrap> getSessionBootstrap();

  Future<AccessStatus> getMyAccess();

  Future<void> touchSession({
    String? appVersion,
    String? timezone,
    int? utcOffsetMinutes,
  });
}

class UserRepository implements IUserRepository {
  final SupabaseService _supabase;

  UserRepository(this._supabase);

  @override
  Future<SessionBootstrap> getSessionBootstrap() {
    return _supabase.rpc(
      SupabaseRpc.getSessionBootstrap,
      mapper: (dynamic data) =>
          SessionBootstrap.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<AccessStatus> getMyAccess() {
    return _supabase.rpc(
      SupabaseRpc.getMyAccess,
      mapper: (dynamic data) =>
          AccessStatus.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<void> touchSession({
    String? appVersion,
    String? timezone,
    int? utcOffsetMinutes,
  }) {
    return _supabase.rpc(
      SupabaseRpc.touchSession,
      params: {
        'p_app_version': appVersion,
        'p_timezone': timezone,
        'p_utc_offset_minutes': utcOffsetMinutes,
      },
      mapper: (_) {},
    );
  }
}
