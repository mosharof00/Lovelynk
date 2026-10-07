import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_models/session_bootstrap.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_pages.dart';
import '../network/api_exception.dart';
import '../utils/helper_utils.dart';
import '../utils/logger.dart';

/// Holds the signed-in user's session data (user, couple, access) for the
/// whole app and keeps it in sync with Supabase Auth.
class SessionService extends GetxService with WidgetsBindingObserver {
  static SessionService get to => Get.find<SessionService>();

  final Rxn<SessionBootstrap> bootstrap = Rxn<SessionBootstrap>();

  StreamSubscription<AuthState>? _authSub;
  bool _signingOut = false;

  IAuthRepository get _authRepo => Get.find<IAuthRepository>();
  IUserRepository get _userRepo => Get.find<IUserRepository>();

  bool get hasSession => Supabase.instance.client.auth.currentSession != null;
  AppUser? get user => bootstrap.value?.user;
  CoupleSummary? get couple => bootstrap.value?.couple;
  AccessStatus? get access => bootstrap.value?.access;
  bool get isPaired => couple != null;

  SessionService init() {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: (Object e) => Log.w('Auth state stream error: $e'),
    );
    WidgetsBinding.instance.addObserver(this);
    return this;
  }

  /// Only app users may use the app; admins sign in to the admin panel.
  bool isAppUser(Session session) {
    final role = session.user.appMetadata['role'];
    return role == null || role == 'user';
  }

  /// Loads `get_session_bootstrap`. Signs out if the account is not allowed
  /// in the app or the session is no longer valid.
  Future<SessionBootstrap> load() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null && !isAppUser(session)) {
      await signOut();
      throw ApiException(
        'This account cannot be used in the app.',
        code: ApiErrorCode.notAppAccount,
      );
    }

    try {
      final data = await _userRepo.getSessionBootstrap();
      bootstrap.value = data;
      HelperUtils.userId = data.user.id;
      HelperUtils.isLogin = true;
      unawaited(touch());
      return data;
    } on ApiException catch (e) {
      if (e.code == '42501') {
        await signOut();
        throw ApiException(e.message, code: ApiErrorCode.notAppAccount);
      }
      if (e.code == '28000' || e.code == 'PGRST301') {
        await signOut();
      }
      rethrow;
    }
  }

  /// Reports app version + timezone; the server throttles `last_seen_at`.
  Future<void> touch() async {
    if (!hasSession) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final tz = await FlutterTimezone.getLocalTimezone();
      await _userRepo.touchSession(
        appVersion: '${info.version}+${info.buildNumber}',
        timezone: tz.identifier,
        utcOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );
    } catch (e) {
      Log.w('touch_session failed: $e');
    }
  }

  Future<void> signOut() async {
    _signingOut = true;
    try {
      await _authRepo.signOut();
    } catch (e) {
      Log.w('Sign out failed, clearing local session anyway: $e');
    } finally {
      _signingOut = false;
    }
    await _clearLocal();
  }

  Future<void> _clearLocal() async {
    bootstrap.value = null;
    await HelperUtils.clearUser();
  }

  void _onAuthStateChange(AuthState state) {
    // Unexpected sign-out while in the app (refresh token revoked, user
    // deleted/banned, signed out elsewhere): send the user to login.
    if (state.event == AuthChangeEvent.signedOut &&
        !_signingOut &&
        bootstrap.value != null) {
      Log.w('Session ended unexpectedly, redirecting to login');
      _clearLocal().then((_) async {
        await HelperUtils.deleteMainControllers();
        Get.offAllNamed(Routes.LOGIN);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && bootstrap.value != null) {
      touch();
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
