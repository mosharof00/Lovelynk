import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/subscription_plan.dart';

class SubscriptionsController extends GetxController {
  late final SubscriptionService _subscription;

  final selectedPlan = SubscriptionPlanId.yearly.obs;

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
    if (_subscription.state.value.planId != null) {
      selectedPlan.value = _subscription.state.value.planId!;
    }
  }

  SubscriptionService get subscription => _subscription;

  bool get isPremium => _subscription.isPremium;

  bool get isOnTrial => _subscription.isOnTrial;

  bool get isWidgetsUnlocked => _subscription.isWidgetsUnlocked;

  bool get canStartTrial => _subscription.canStartTrial;

  int? get trialDaysRemaining => _subscription.trialDaysRemaining;

  void selectPlan(SubscriptionPlanId plan) => selectedPlan.value = plan;

  Future<void> startFreeTrial() async {
    if (!canStartTrial) return;
    await _subscription.startTrial();
    Get.back();
    Get.snackbar(
      'Trial started',
      'All widgets unlocked for 7 days.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.primaryLight,
      colorText: AppColor.textPrimary,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> subscribe() async {
    await _subscription.subscribe(selectedPlan.value);
    Get.back();
    Get.snackbar(
      'Subscribed',
      'Welcome to Lovelynk Premium!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.primaryLight,
      colorText: AppColor.textPrimary,
      margin: const EdgeInsets.all(16),
    );
  }

  void onManageTap() {
    // TODO(StoreKit): open App Store subscription management.
  }
}
