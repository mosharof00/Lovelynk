import 'package:get/get.dart';

import '../../data/models/widget_models/subscription_state.dart';

/// Mock subscription for Phase 1 UI (Option B: all open on trial, then all locked).
/// Replace with StoreKit later.
class SubscriptionService extends GetxService {
  final state = SubscriptionState.trial().obs;

  bool get isWidgetsUnlocked => state.value.isWidgetsUnlocked;

  void startTrial() {
    state.value = SubscriptionState.trial();
  }

  void activateSubscription() {
    state.value = SubscriptionState.active();
  }

  void expireTrial() {
    state.value = SubscriptionState.expired();
  }

  /// Placeholder for later WidgetKit soft-lock:
  /// when expired, stop writing live data and write status "locked".
  String? get widgetLockMessage =>
      isWidgetsUnlocked ? null : 'Locked';
}
