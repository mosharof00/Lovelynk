import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_models/session_bootstrap.dart';
import '../../global/widgets/initials_avatar.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_pages.dart';
import '../network/api_exception.dart';
import '../network/supabase/supabase_endpoints.dart';
import 'local_store_service.dart';
import '../utils/helper_utils.dart';
import '../utils/logger.dart';
import '../widgets/widget_sync_service.dart';
import 'subscription_service.dart';

enum CoupleEvent { paired, left }

/// Single source of truth for the signed-in user's state (profile, couple,
/// access). Screens read [bootstrap] / the getters below and react with
/// `Obx` / `ever`, so pairing or disconnecting updates every screen at once.
class SessionService extends GetxService with WidgetsBindingObserver {
  static SessionService get to => Get.find<SessionService>();

  final Rxn<SessionBootstrap> bootstrap = Rxn<SessionBootstrap>();

  /// Pairing changes pushed by the server (realtime) or detected on refresh.
  /// True when the latest [load] failed (offline / server error).
  final lastLoadFailed = false.obs;

  final _coupleEvents = StreamController<CoupleEvent>.broadcast();
  Stream<CoupleEvent> get coupleEvents => _coupleEvents.stream;

  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _channel;
  bool _signingOut = false;

  IAuthRepository get _authRepo => Get.find<IAuthRepository>();
  IUserRepository get _userRepo => Get.find<IUserRepository>();
  SupabaseClient get _client => Supabase.instance.client;

  bool get hasSession => _client.auth.currentSession != null;
  AppUser? get user => bootstrap.value?.user;
  CoupleSummary? get couple => bootstrap.value?.couple;
  PartnerSummary? get partner => couple?.partner;
  AccessStatus? get access => bootstrap.value?.access;
  PartnerLiveSnapshot? get partnerLive => bootstrap.value?.partnerLive;
  bool get isPaired => couple != null;
  bool get isLocationSharingEnabled =>
      bootstrap.value?.user.locationSharingEnabled ?? true;
  bool get isPartnerLocationSharingEnabled =>
      bootstrap.value?.partnerLive?.locationSharingEnabled ??
      (bootstrap.value?.couple?.partner.locationSharingEnabled ?? true);

  static const _recoveryPendingKey = 'password_recovery_pending';

  /// True between a verified recovery code and saving the new password.
  /// That session must not be used to enter the app.
  bool get isRecoveryPending =>
      HiveService.read<bool>(_recoveryPendingKey) ?? false;

  void setRecoveryPending(bool value) =>
      HiveService.write(_recoveryPendingKey, value);

  SessionService init() {
    _authSub = _client.auth.onAuthStateChange.listen(
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
    final session = _client.auth.currentSession;
    if (session != null && !isAppUser(session)) {
      await signOut();
      throw ApiException(
        'This account cannot be used in the app.',
        code: ApiErrorCode.notAppAccount,
      );
    }

    try {
      final data = await _userRepo.getSessionBootstrap();
      apply(data);
      lastLoadFailed.value = false;
      unawaited(touch());
      _subscribeRealtime();
      return data;
    } on ApiException catch (e) {
      lastLoadFailed.value = true;
      if (e.code == '42501') {
        await signOut();
        throw ApiException(e.message, code: ApiErrorCode.notAppAccount);
      }
      if (e.code == '28000' || e.code == 'PGRST301') {
        await signOut();
      }
      rethrow;
    } catch (_) {
      lastLoadFailed.value = true;
      rethrow;
    }
  }

  /// Best-effort reload (resume, realtime event, polling). Never throws.
  Future<void> refresh() async {
    if (!hasSession || bootstrap.value == null) return;
    try {
      await load();
    } catch (e) {
      Log.w('Session refresh failed: $e');
    }
  }

  /// Sets new session data (e.g. returned by accept_invite / leave_couple)
  /// and emits a [CoupleEvent] when the paired state flips.
  void apply(SessionBootstrap data) {
    final wasPaired = bootstrap.value?.isPaired;
    bootstrap.value = data;
    HelperUtils.userId = data.user.id;
    HelperUtils.isLogin = true;

    if (wasPaired != null && wasPaired != data.isPaired) {
      _coupleEvents.add(data.isPaired ? CoupleEvent.paired : CoupleEvent.left);
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
    await _unsubscribeRealtime();
    try {
      await _authRepo.signOut();
    } catch (e) {
      Log.w('Sign out failed, clearing local session anyway: $e');
    } finally {
      _signingOut = false;
    }
    await _clearLocal();
  }

  /// After the account was deleted on the server: the session is already
  /// invalid, so only local state is cleared.
  Future<void> onAccountDeleted() async {
    _signingOut = true;
    await _unsubscribeRealtime();
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
    } finally {
      _signingOut = false;
    }
    await _clearLocal();
  }

  /// Everything tied to the signed-in account, so the next account on this
  /// device starts clean (app state, local subscription, home widgets).
  Future<void> _clearLocal() async {
    bootstrap.value = null;
    lastLoadFailed.value = false;
    setRecoveryPending(false);
    AvatarUrlCache.clear();
    if (Get.isRegistered<SubscriptionService>()) {
      Get.find<SubscriptionService>().clear();
    }
    if (Get.isRegistered<WidgetSyncService>()) {
      await Get.find<WidgetSyncService>().clearUserData();
    }
    await HelperUtils.clearUser();
  }

  // ── Realtime (foreground only, one private channel per user) ──────

  void _subscribeRealtime() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || _channel != null) return;

    _channel = _client
        .channel(
          SupabaseRealtime.userTopic(uid),
          opts: const RealtimeChannelConfig(private: true),
        )
        .onBroadcast(
          event: SupabaseRealtime.couplePaired,
          callback: (_) => refresh(),
        )
        .onBroadcast(
          event: SupabaseRealtime.coupleLeft,
          callback: (_) => refresh(),
        )
        .onBroadcast(
          event: SupabaseRealtime.coupleUpdated,
          callback: (_) => refresh(),
        )
        .onBroadcast(
          event: SupabaseRealtime.partnerLocation,
          callback: (_) => refreshPartnerSnapshot(),
        )
        .subscribe((status, error) {
          Log.i('[Realtime] user channel: $status ${error ?? ''}');
        });
  }

  /// Lightweight refresh of partner snapshot only (called on partner.location).
  Future<void> refreshPartnerSnapshot() async {
    if (!hasSession || !isPaired) return;
    try {
      final snap = await _userRepo.getPartnerSnapshot();
      if (snap != null && bootstrap.value != null) {
        final current = bootstrap.value!;
        bootstrap.value = SessionBootstrap(
          user: current.user,
          couple: current.couple,
          access: current.access,
          partnerLive: snap,
        );
      }
    } catch (e) {
      Log.w('refreshPartnerSnapshot failed: $e');
    }
  }

  Future<void> _unsubscribeRealtime() async {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      try {
        await _client.removeChannel(channel);
      } catch (e) {
        Log.w('[Realtime] remove channel failed: $e');
      }
    }
  }

  void _onAuthStateChange(AuthState state) {
    // Unexpected sign-out while in the app (refresh token revoked, user
    // deleted/banned, signed out elsewhere): send the user to login.
    if (state.event == AuthChangeEvent.signedOut &&
        !_signingOut &&
        bootstrap.value != null) {
      Log.w('Session ended unexpectedly, redirecting to login');
      _unsubscribeRealtime();
      _clearLocal().then((_) async {
        await HelperUtils.deleteMainControllers();
        Get.offAllNamed(Routes.LOGIN);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (bootstrap.value == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        // Catches anything missed while in the background and resubscribes.
        _subscribeRealtime();
        refresh();
        break;
      case AppLifecycleState.paused:
        _unsubscribeRealtime();
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _unsubscribeRealtime();
    _coupleEvents.close();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
