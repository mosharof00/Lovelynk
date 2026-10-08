import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/app_config.dart';
import '../../utils/logger.dart';
import '../api_exception.dart';
import 'secure_session_storage.dart';

/// Supabase counterpart of [ApiClient]: owns the client and wraps every call
/// so repositories only ever see [ApiException].
class SupabaseService extends GetxService {
  /// Call once in `main()` after Hive is initialised.
  static Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
        detectSessionInUri: false,
      ),
      debug: kDebugMode,
    );
    return SupabaseService();
  }

  SupabaseClient get client => Supabase.instance.client;

  GoTrueClient get auth => client.auth;

  Session? get currentSession => auth.currentSession;

  User? get currentUser => auth.currentUser;

  Future<T> handleRequest<T>(
    Future<dynamic> Function() request,
    T Function(dynamic data) mapper,
    String apiName,
  ) async {
    try {
      Log.i('[$apiName] Request started');
      final data = await request();
      return mapper(data);
    } catch (e, stacktrace) {
      final exception = ApiException.fromSupabase(e);
      Log.e('[$apiName] $exception\nCause: $e');
      if (exception.code == null) Log.e(stacktrace);
      throw exception;
    }
  }

  Future<T> rpc<T>(
    String function, {
    Map<String, dynamic>? params,
    required T Function(dynamic data) mapper,
  }) {
    return handleRequest(
      () => client.rpc(function, params: params),
      mapper,
      'RPC $function',
    );
  }
}
