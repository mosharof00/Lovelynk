import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/subscription_plan.dart';

class SubscriptionsController extends GetxController {
  late final SubscriptionService _subscription;

  final selectedPlan = SubscriptionPlanId.yearly.obs;
  final isPurchasing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
    if (_subscription.state.value.planId != null) {
      selectedPlan.value = _subscription.state.value.planId!;
    }
    // Fetch offerings if not already loaded
    if (_subscription.isConfigured.value && _subscription.offerings.value == null) {
      _subscription.fetchOfferings();
    }
  }

  SubscriptionService get subscription => _subscription;

  bool get isPremium => _subscription.isPremium;

  bool get isOnTrial => _subscription.isOnTrial;

  bool get isWidgetsUnlocked => _subscription.isWidgetsUnlocked;

  bool get isPartnerShared => _subscription.isPartnerShared;

  bool get canStartTrial => _subscription.canStartTrial;

  int? get trialDaysRemaining => _subscription.trialDaysRemaining;

  Package? get monthlyPackage =>
      _subscription.offerings.value?.current?.monthly;

  Package? get annualPackage =>
      _subscription.offerings.value?.current?.annual;

  String get monthlyPriceString =>
      monthlyPackage?.storeProduct.priceString ?? '£6.99';

  String get yearlyPriceString =>
      annualPackage?.storeProduct.priceString ?? '£29.99';

  void selectPlan(SubscriptionPlanId plan) => selectedPlan.value = plan;

  /// Triggered from paywall primary button.
  Future<void> onPrimaryAction() async {
    if (isPurchasing.value) return;

    if (canStartTrial) {
      await _purchaseSelectedPlan(isTrialIntent: true);
    } else {
      await _purchaseSelectedPlan(isTrialIntent: false);
    }
  }

  Future<void> _purchaseSelectedPlan({required bool isTrialIntent}) async {
    isPurchasing.value = true;
    try {
      if (_subscription.isConfigured.value) {
        final package = selectedPlan.value == SubscriptionPlanId.yearly
            ? annualPackage
            : monthlyPackage;

        if (package != null) {
          final customerInfo = await _subscription.purchasePackage(package);
          if (customerInfo == null) {
            // User cancelled StoreKit sheet — do nothing
            return;
          }
        } else {
          // If offerings not resolved yet, fallback to simulation
          await _subscription.subscribe(selectedPlan.value);
        }
      } else {
        // Development / Sandbox simulation
        if (isTrialIntent) {
          await _subscription.startTrial();
        } else {
          await _subscription.subscribe(selectedPlan.value);
        }
      }

      Get.back();
      Get.snackbar(
        isTrialIntent ? 'Trial Started' : 'Welcome to LoveLynk Plus',
        isTrialIntent
            ? 'All couple widgets and features unlocked for 7 days.'
            : 'You and your partner now have unlimited access.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryLight,
        colorText: AppColor.textPrimary,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return;
      }
      String errorMessage = 'Unable to complete purchase. Please try again.';
      if (code == PurchasesErrorCode.paymentPendingError) {
        errorMessage = 'Your purchase is pending bank or parental approval.';
      } else if (code == PurchasesErrorCode.networkError) {
        errorMessage = 'Network connection failed. Please check your internet.';
      } else if (code == PurchasesErrorCode.productAlreadyPurchasedError) {
        errorMessage = 'You already have an active subscription. Restoring...';
        await restorePurchases();
        return;
      }

      Get.snackbar(
        'Purchase Issue',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isPurchasing.value = false;
    }
  }

  void onManageTap() {
    _subscription.showManageSubscriptions();
  }

  Future<void> restorePurchases() async {
    if (isPurchasing.value) return;
    isPurchasing.value = true;
    try {
      if (_subscription.isConfigured.value) {
        await _subscription.restorePurchases();
        if (_subscription.isPremium) {
          Get.back();
          Get.snackbar(
            'Purchases Restored',
            'Your LoveLynk Plus access has been successfully restored.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.primaryLight,
            colorText: AppColor.textPrimary,
            margin: const EdgeInsets.all(16),
          );
        } else {
          Get.snackbar(
            'Restore Completed',
            'No active LoveLynk Plus subscription was found for this Apple ID.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColor.primaryLight,
            colorText: AppColor.textPrimary,
            margin: const EdgeInsets.all(16),
          );
        }
      } else {
        Get.snackbar(
          'Restore',
          'Purchases restored from local cache.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.primaryLight,
          colorText: AppColor.textPrimary,
          margin: const EdgeInsets.all(16),
        );
      }
    } on PlatformException catch (e) {
      Get.snackbar(
        'Restore Failed',
        e.message ?? 'Failed to restore purchases from App Store.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isPurchasing.value = false;
    }
  }
}
