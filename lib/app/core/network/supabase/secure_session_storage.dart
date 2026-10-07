import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/local_store_service.dart';

/// Persists the Supabase session (access + refresh token) in the Keychain /
/// Keystore instead of plain SharedPreferences.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage();

  static const _sessionKey = 'lovelynk.supabase.session';
  static const _installMarkerKey = 'supabase_session_install_marker';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {
    // The iOS Keychain survives an uninstall but Hive (app documents) doesn't,
    // so a missing marker means a fresh install: drop any stale session.
    if (HiveService.read<bool>(_installMarkerKey) != true) {
      await _storage.delete(key: _sessionKey);
      HiveService.write(_installMarkerKey, true);
    }
  }

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _sessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: _sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _sessionKey, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _sessionKey);
}
