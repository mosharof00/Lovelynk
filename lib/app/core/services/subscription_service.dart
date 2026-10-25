import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/user_models/session_bootstrap.dart';
import '../../data/models/widget_models/subscription_plan.dart';
import '../../data/models/widget_models/subscription_state.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import '../widgets/widget_sync_service.dart';
import 'local_store_service.dart';

/// Single source of truth for subscription / premium access across the app.
///
/// Features:
/// 1. Backed by RevenueCat StoreKit 2 integration on iOS.
/// 2. Driven by Supabase backend `access` (mirroring RevenueCat webhooks),
///    supporting couple-shared premium (user A pays, partner B gets access).
/// 3. Instant local entitlement updates on purchase or restore.
class SubscriptionService extends GetxService {
  static SubscriptionService get to => Get.find<SubscriptionService>();

  static const _statusKey = 'subscription_status';
  static const _trialEndsKey = 'subscription_trial_ends_at';
  static const _planIdKey = 'subscription_plan_id';
  static const _hasUsedTrialKey = 'subscription_has_used_trial';
  static const _accessSourceKey = 'subscription_access_source';

  final state = SubscriptionState.expired().obs;
  final hasUsedTrial = false.obs;
  final isLoading = false.obs;
  final isConfigured = false.obs;
  final offerings = Rxn<Offerings>();

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
    evaluateTrialExpiry();
    _initRevenueCat();
  }

  // ── Public getters ──────────────────────────────────────────────────────

  bool get isPremium => state.value.isPremium;

  bool get isOnTrial => state.value.isOnTrial;

  bool get isWidgetsUnlocked => state.value.isWidgetsUnlocked;

  bool get isPartnerShared => state.value.isPartnerShared;

  bool get isSelfPurchased => state.value.isSelfPurchased;

  bool get canStartTrial => !hasUsedTrial.value && !isPremium && !isOnTrial;

  int? get trialDaysRemaining => state.value.trialDaysRemaining;

  SubscriptionPlan? get activePlan =>
      SubscriptionPlan.fromId(state.value.planId);

  String? get widgetLockMessage =>
      isWidgetsUnlocked ? null : 'Subscribe to unlock widgets';

  // ── RevenueCat Initialization ──────────────────────────────────────────

  Future<void> _initRevenueCat() async {
    // Only iOS currently supported for in-app subscriptions
    if (!kIsWeb && !Platform.isIOS && !Platform.isMacOS) {
      Log.i('[RevenueCat] Skipping initialization on unsupported platform.');
      return;
    }

    final apiKey = AppConfig.revenueCatAppleApiKey;
    if (apiKey.isEmpty || apiKey == 'appl_placeholder_key') {
      Log.w('[RevenueCat] Placeholder API key detected. StoreKit purchase calls will be simulated.');
      return;
    }

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      isConfigured.value = true;
      Log.i('[RevenueCat] Configured successfully with Apple key.');

      // Listen for background entitlement updates from StoreKit
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch initial offerings in the background
      unawaited(fetchOfferings());
    } catch (e) {
      Log.e('[RevenueCat] Configure failed: $e');
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    Log.i('[RevenueCat] CustomerInfo updated listener triggered.');
    _applyFromCustomerInfo(customerInfo);
  }

  // ── Auth Identity Lifecycle ─────────────────────────────────────────────

  /// Called after successful Supabase login.
  /// Binds the user's Supabase UUID to RevenueCat so purchases belong to them.
  Future<void> logInUser(String supabaseUserId) async {
    if (!isConfigured.value) return;
    try {
      final logInResult = await Purchases.logIn(supabaseUserId);
      Log.i('[RevenueCat] Logged in user: $supabaseUserId (created=${logInResult.created})');
      _applyFromCustomerInfo(logInResult.customerInfo);
    } catch (e) {
      Log.w('[RevenueCat] Purchases.logIn failed: $e');
    }
  }

  /// Called on user sign out / account deletion.
  /// Resets RevenueCat identity back to an anonymous ID so the next account on this device starts clean.
  Future<void> logOutUser() async {
    clear();
    if (!isConfigured.value) return;
    try {
      await Purchases.logOut();
      Log.i('[RevenueCat] Purchases.logOut completed.');
    } catch (e) {
      Log.w('[RevenueCat] Purchases.logOut error: $e');
    }
  }

  // ── Offerings & Purchases ───────────────────────────────────────────────

  /// Loads dynamic offerings from RevenueCat dashboard.
  Future<Offerings?> fetchOfferings() async {
    if (!isConfigured.value) return null;
    try {
      final off = await Purchases.getOfferings();
      offerings.value = off;
      Log.i('[RevenueCat] Offerings fetched: ${off.current?.availablePackages.length ?? 0} packages');
      return off;
    } catch (e) {
      Log.w('[RevenueCat] Failed to fetch offerings: $e');
      return null;
    }
  }

  /// Purchase a package using StoreKit 2 sheet.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!isConfigured.value) {
      throw PlatformException(
        code: 'not_configured',
        message: 'In-app purchases are not configured for this build.',
      );
    }

    try {
      isLoading.value = true;
      final purchaseResult =
          await Purchases.purchase(PurchaseParams.package(package));
      final customerInfo = purchaseResult.customerInfo;
      _applyFromCustomerInfo(customerInfo);
      await _syncWidgets();
      return customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        Log.i('[RevenueCat] User cancelled purchase.');
        return null;
      }
      Log.e('[RevenueCat] Purchase error (${e.code}): ${e.message}');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore previous purchases from Apple ID.
  Future<CustomerInfo?> restorePurchases() async {
    if (!isConfigured.value) {
      throw PlatformException(
        code: 'not_configured',
        message: 'In-app purchases are not configured for this build.',
      );
    }

    try {
      isLoading.value = true;
      final customerInfo = await Purchases.restorePurchases();
      _applyFromCustomerInfo(customerInfo);
      await _syncWidgets();
      return customerInfo;
    } on PlatformException catch (e) {
      Log.e('[RevenueCat] Restore purchases error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Open Apple StoreKit subscription management screen.
  Future<void> showManageSubscriptions() async {
    try {
      final uri = Uri.parse('https://apps.apple.com/account/subscriptions');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      Log.w('[RevenueCat] showManageSubscriptions failed: $e');
    }
  }

  // ── Sync with Supabase Server Access ─────────────────────────────────────

  /// Apply access status received from server bootstrap (`get_session_bootstrap` / `get_my_access`).
  /// This is the master source of truth, supporting couple-shared premium.
  void applyFromAccess(AccessStatus? access) {
    if (access == null) return;

    if (access.isPremium) {
      final planId = access.plan == 'yearly'
          ? SubscriptionPlanId.yearly
          : SubscriptionPlanId.monthly;

      state.value = SubscriptionState(
        status: access.isTrial
            ? SubscriptionStatus.trial
            : SubscriptionStatus.active,
        planId: planId,
        trialEndsAt: access.isTrial ? access.expiresAt : null,
        accessSource: access.source,
        expiresAt: access.expiresAt,
        willRenew: access.willRenew,
      );
      if (access.isTrial) {
        hasUsedTrial.value = true;
      }
    } else {
      state.value = const SubscriptionState(
        status: SubscriptionStatus.expired,
        accessSource: AccessSource.none,
      );
    }

    _persist();
    evaluateTrialExpiry();
    _syncWidgets();

    Log.i(
      '[Subscription] Applied server access — isPremium=$isPremium, '
      'source=${state.value.accessSource.name}, plan=${state.value.planId?.name}',
    );
  }

  void _applyFromCustomerInfo(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[AppConfig.entitlementPlus];
    final isActive = entitlement?.isActive ?? false;

    if (isActive) {
      final isTrial = entitlement?.periodType == PeriodType.trial;
      final prodId = entitlement?.productIdentifier ?? '';
      final isYearly = prodId.toLowerCase().contains('year') ||
          prodId.toLowerCase().contains('annual');
      final planId = isYearly ? SubscriptionPlanId.yearly : SubscriptionPlanId.monthly;

      DateTime? expiresAt;
      if (entitlement?.expirationDate != null) {
        expiresAt = DateTime.tryParse(entitlement!.expirationDate!);
      }

      state.value = SubscriptionState(
        status: isTrial ? SubscriptionStatus.trial : SubscriptionStatus.active,
        planId: planId,
        trialEndsAt: isTrial ? expiresAt : null,
        accessSource: AccessSource.self,
        expiresAt: expiresAt,
        willRenew: entitlement?.willRenew,
      );
      if (isTrial) hasUsedTrial.value = true;
    } else {
      // If server access gave us partner-shared access, do not downgrade just because
      // self doesn't have an active personal Apple receipt.
      if (!state.value.isPartnerShared) {
        state.value = const SubscriptionState(
          status: SubscriptionStatus.expired,
          accessSource: AccessSource.none,
        );
      }
    }

    _persist();
    evaluateTrialExpiry();
  }

  // ── Mock & Actions (For local simulation / testing) ─────────────────────

  Future<void> startTrial() async {
    if (hasUsedTrial.value) {
      Log.w('[Subscription] Trial already used — cannot start again.');
      return;
    }
    state.value = SubscriptionState.trial();
    hasUsedTrial.value = true;
    await _persist();
    Log.i('[Subscription] 7-day free trial started.');
    await _syncWidgets();
  }

  Future<void> subscribe(SubscriptionPlanId planId) async {
    state.value = SubscriptionState.active(planId: planId);
    await _persist();
    Log.i('[Subscription] Subscribed — plan=${planId.name}.');
    await _syncWidgets();
  }

  Future<void> expireTrial() async {
    if (!state.value.isOnTrial) return;
    state.value = SubscriptionState.expired();
    await _persist();
    Log.i('[Subscription] Trial expired — widgets locked.');
    await _syncWidgets();
  }

  /// Logout: forget this account's state so the next one starts clean.
  void clear() {
    for (final key in [
      _statusKey,
      _trialEndsKey,
      _planIdKey,
      _hasUsedTrialKey,
      _accessSourceKey
    ]) {
      HiveService.box?.delete(key);
    }
    state.value = SubscriptionState.expired();
    hasUsedTrial.value = false;
  }

  // ── Storage ─────────────────────────────────────────────────────────────

  void loadFromStorage() {
    final storedStatus = HiveService.read<String>(_statusKey);
    if (storedStatus == null) {
      state.value = SubscriptionState.expired();
      hasUsedTrial.value = HiveService.read<bool>(_hasUsedTrialKey) ?? false;
      return;
    }

    final sourceName = HiveService.read<String>(_accessSourceKey);
    final accessSource = AccessSource.values.firstWhere(
      (s) => s.name == sourceName,
      orElse: () => AccessSource.none,
    );

    state.value = SubscriptionState.fromStorage({
      'status': storedStatus,
      'trialEndsAt': HiveService.read<String>(_trialEndsKey),
      'planId': HiveService.read<String>(_planIdKey),
      'accessSource': accessSource.name,
    });
    hasUsedTrial.value = HiveService.read<bool>(_hasUsedTrialKey) ?? false;
  }

  Future<void> _persist() async {
    final current = state.value;
    HiveService.write(_statusKey, current.status.name);
    if (current.trialEndsAt != null) {
      HiveService.write(_trialEndsKey, current.trialEndsAt!.toIso8601String());
    } else {
      HiveService.box?.delete(_trialEndsKey);
    }
    if (current.planId != null) {
      HiveService.write(_planIdKey, current.planId!.name);
    } else {
      HiveService.box?.delete(_planIdKey);
    }
    HiveService.write(_accessSourceKey, current.accessSource.name);
    HiveService.write(_hasUsedTrialKey, hasUsedTrial.value);
  }

  /// Auto-expire trial when past end date.
  void evaluateTrialExpiry() {
    if (!state.value.isOnTrial) return;
    final endsAt = state.value.trialEndsAt;
    if (endsAt != null && DateTime.now().isAfter(endsAt)) {
      state.value = SubscriptionState.expired();
      _persist();
      Log.i('[Subscription] Trial auto-expired on app open.');
      _syncWidgets();
    }
  }

  Future<void> _syncWidgets() async {
    if (Get.isRegistered<WidgetSyncService>()) {
      await Get.find<WidgetSyncService>().syncAll();
    }
  }
}
