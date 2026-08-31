import 'package:get/get.dart';

import '../../data/models/widget_models/subscription_plan.dart';
import '../../data/models/widget_models/subscription_state.dart';
import '../utils/logger.dart';
import '../widgets/widget_sync_service.dart';
import 'local_store_service.dart';

/// Single source of truth for subscription / premium access across the app.
///
/// - [isPremium] — paid subscriber (profile badge, billing UI)
/// - [isWidgetsUnlocked] — trial OR paid (widget access)
///
/// [HomeController.refreshSubscription] re-fetches from backend later;
/// until then this service loads from local storage on init.
class SubscriptionService extends GetxService {
  static const _statusKey = 'subscription_status';
  static const _trialEndsKey = 'subscription_trial_ends_at';
  static const _planIdKey = 'subscription_plan_id';
  static const _hasUsedTrialKey = 'subscription_has_used_trial';

  final state = SubscriptionState.expired().obs;
  final hasUsedTrial = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
    evaluateTrialExpiry();
  }

  // ── Public getters ──────────────────────────────────────────────────────

  bool get isPremium => state.value.isPremium;

  bool get isOnTrial => state.value.isOnTrial;

  bool get isWidgetsUnlocked => state.value.isWidgetsUnlocked;

  bool get canStartTrial => !hasUsedTrial.value && !isPremium && !isOnTrial;

  int? get trialDaysRemaining => state.value.trialDaysRemaining;

  SubscriptionPlan? get activePlan =>
      SubscriptionPlan.fromId(state.value.planId);

  String? get widgetLockMessage =>
      isWidgetsUnlocked ? null : 'Subscribe to unlock widgets';

  // ── Bootstrap (called from HomeController after user fetch) ─────────────

  /// Refresh subscription for the logged-in user.
  /// TODO(Supabase): replace storage read with user profile API response.
  Future<void> refreshFromUser() async {
    isLoading.value = true;
    try {
      loadFromStorage();
      evaluateTrialExpiry();
      Log.i(
        '[Subscription] Refreshed — premium=$isPremium, '
        'widgetsUnlocked=$isWidgetsUnlocked, trialUsed=${hasUsedTrial.value}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply subscription fields from backend user payload (future).
  void applyFromUser({
    required SubscriptionStatus status,
    DateTime? trialEndsAt,
    SubscriptionPlanId? planId,
    bool? usedTrial,
  }) {
    state.value = SubscriptionState(
      status: status,
      trialEndsAt: trialEndsAt,
      planId: planId,
    );
    if (usedTrial != null) hasUsedTrial.value = usedTrial;
    _persist();
    evaluateTrialExpiry();
  }

  // ── Actions ─────────────────────────────────────────────────────────────

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

  // ── Storage ─────────────────────────────────────────────────────────────

  void loadFromStorage() {
    final storedStatus = HiveService.read<String>(_statusKey);
    if (storedStatus == null) {
      state.value = SubscriptionState.expired();
      hasUsedTrial.value = HiveService.read<bool>(_hasUsedTrialKey) ?? false;
      return;
    }

    state.value = SubscriptionState.fromStorage({
      'status': storedStatus,
      'trialEndsAt': HiveService.read<String>(_trialEndsKey),
      'planId': HiveService.read<String>(_planIdKey),
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
