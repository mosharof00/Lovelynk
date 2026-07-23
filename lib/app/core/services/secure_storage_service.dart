import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecureStorageService._internal();

  // Keys
  static const _userIdKey = 'user_id';
  static const _tokenKey = 'access_token';
  static const _userRoleKey = 'user_role';

  // -----------------------------
  // User ID
  // -----------------------------
  Future<void> setUserID(String id) async =>
      await _storage.write(key: _userIdKey, value: id);

  Future<String?> getUserID() async => await _storage.read(key: _userIdKey);

  Future<void> deleteUserID() async => await _storage.delete(key: _userIdKey);

  // -----------------------------
  // Token
  // -----------------------------
  Future<void> setToken(String token) async =>
      await _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() async => await _storage.read(key: _tokenKey);

  Future<void> deleteToken() async => await _storage.delete(key: _tokenKey);

  // -----------------------------
  // User Role
  // -----------------------------
  Future<void> setUserRole(String role) async =>
      await _storage.write(key: _userRoleKey, value: role);

  Future<String?> getUserRole() async => await _storage.read(key: _userRoleKey);

  Future<void> deleteUserRole() async => await _storage.delete(key: _userRoleKey);

  // -----------------------------
  // Clear all user data
  // -----------------------------
  Future<void> clearAll() async => await _storage.deleteAll();
}