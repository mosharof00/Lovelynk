import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/supabase/supabase_endpoints.dart';
import '../../core/network/supabase/supabase_service.dart';
import '../models/user_models/session_bootstrap.dart';

/// Matches the `ticket_category` enum.
enum SupportCategory { general, bug, billing, account, feedback }

abstract class IUserRepository {
  Future<SessionBootstrap> getSessionBootstrap();

  Future<AccessStatus> getMyAccess();

  Future<void> touchSession({
    String? appVersion,
    String? timezone,
    int? utcOffsetMinutes,
  });

  /// `null` leaves a field unchanged; `avatarPath: ''` removes the photo.
  Future<SessionBootstrap> updateProfile({String? fullName, String? avatarPath});

  /// Uploads a JPEG to `avatars/{uid}/…` and returns its storage path.
  Future<String> uploadAvatar(Uint8List bytes);

  Future<void> deleteAvatarFile(String path);

  /// Short-lived URL for a private avatar (owner or partner only).
  Future<String> avatarUrl(String path, {int expiresInSeconds});

  /// Uploads to `support-attachments/{uid}/…` and returns its storage path.
  Future<String> uploadSupportAttachment(Uint8List bytes, {required String extension});

  Future<void> submitSupportTicket({
    required SupportCategory category,
    required String subject,
    required String message,
    List<String> attachmentPaths,
    String? appVersion,
    String? deviceModel,
    String? osVersion,
  });

  /// Permanently deletes the signed-in account on the server.
  Future<void> deleteAccount();
}

class UserRepository implements IUserRepository {
  final SupabaseService _supabase;

  UserRepository(this._supabase);

  String get _uid => _supabase.currentUser!.id;

  @override
  Future<SessionBootstrap> getSessionBootstrap() {
    return _supabase.rpc(
      SupabaseRpc.getSessionBootstrap,
      mapper: _bootstrap,
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

  @override
  Future<SessionBootstrap> updateProfile({String? fullName, String? avatarPath}) {
    return _supabase.rpc(
      SupabaseRpc.updateMyProfile,
      params: {'p_full_name': fullName, 'p_avatar_path': avatarPath},
      mapper: _bootstrap,
    );
  }

  @override
  Future<String> uploadAvatar(Uint8List bytes) {
    final path = '$_uid/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return _supabase.handleRequest(
      () => _supabase.client.storage.from(SupabaseBucket.avatars).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          ),
      (_) => path,
      'Upload avatar',
    );
  }

  @override
  Future<void> deleteAvatarFile(String path) {
    return _supabase.handleRequest(
      () => _supabase.client.storage.from(SupabaseBucket.avatars).remove([path]),
      (_) {},
      'Delete avatar file',
    );
  }

  @override
  Future<String> avatarUrl(String path, {int expiresInSeconds = 60 * 60 * 24}) {
    return _supabase.handleRequest(
      () => _supabase.client.storage
          .from(SupabaseBucket.avatars)
          .createSignedUrl(path, expiresInSeconds),
      (dynamic data) => data as String,
      'Avatar URL',
    );
  }

  @override
  Future<String> uploadSupportAttachment(
    Uint8List bytes, {
    required String extension,
  }) {
    final ext = extension.toLowerCase();
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      _ => 'image/jpeg',
    };
    final path = '$_uid/${DateTime.now().microsecondsSinceEpoch}.$ext';
    return _supabase.handleRequest(
      () => _supabase.client.storage
          .from(SupabaseBucket.supportAttachments)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          ),
      (_) => path,
      'Upload support attachment',
    );
  }

  @override
  Future<void> submitSupportTicket({
    required SupportCategory category,
    required String subject,
    required String message,
    List<String> attachmentPaths = const [],
    String? appVersion,
    String? deviceModel,
    String? osVersion,
  }) {
    return _supabase.rpc(
      SupabaseRpc.submitSupportTicket,
      params: {
        'p_category': category.name,
        'p_subject': subject.trim(),
        'p_message': message.trim(),
        'p_attachment_paths': attachmentPaths,
        'p_app_version': appVersion,
        'p_device_model': deviceModel,
        'p_os_version': osVersion,
      },
      mapper: (_) {},
    );
  }

  @override
  Future<void> deleteAccount() {
    return _supabase.handleRequest(
      () => _supabase.client.functions.invoke(
        SupabaseFunction.deleteAccount,
        method: HttpMethod.post,
      ),
      (_) {},
      'Delete account',
    );
  }

  static SessionBootstrap _bootstrap(dynamic data) =>
      SessionBootstrap.fromJson(Map<String, dynamic>.from(data as Map));
}
