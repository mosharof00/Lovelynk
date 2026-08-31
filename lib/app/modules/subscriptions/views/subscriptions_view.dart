import 'package:bulkretail/app/global/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/subscription_plan.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionsView extends GetView<SubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const CustomAppBar(title: 'Subscription', showBackButton: true),
      body: Obx(() {
        final sub = controller.subscription;
        final state = sub.state.value;

        return ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
          children: [
            const _HeroHeader(),
            20.verticalSpace,
            _StatusCard(
              isPremium: state.isPremium,
              isOnTrial: state.isOnTrial,
              trialDaysRemaining: sub.trialDaysRemaining,
              activePlan: sub.activePlan,
            ),
            24.verticalSpace,
            AppText(
              'Choose your plan',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            8.verticalSpace,
            AppText(
              'Unlock all 12 widgets for you and your partner.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary,
                height: 1.4,
              ),
            ),
            16.verticalSpace,
            for (final plan in SubscriptionPlan.all) ...[
              _PlanCard(
                plan: plan,
                isSelected: controller.selectedPlan.value == plan.id,
                onTap: () => controller.selectPlan(plan.id),
              ),
              12.verticalSpace,
            ],
            8.verticalSpace,
            const _FeatureList(),
            24.verticalSpace,
            if (controller.canStartTrial) ...[
              GlobalButton(
                onTap: controller.startFreeTrial,
                text: 'Start 7-day free trial',
                color: AppColor.secondary,
              ),
              12.verticalSpace,
              AppText(
                'One-time offer. All widgets unlocked during trial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColor.hintText,
                ),
              ),
              16.verticalSpace,
            ],
            if (!state.isPremium) ...[
              GlobalButton(
                onTap: controller.subscribe,
                text: state.isOnTrial
                    ? 'Subscribe now'
                    : 'Continue with ${SubscriptionPlan.fromId(controller.selectedPlan.value)?.title ?? 'plan'}',
              ),
            ] else ...[
              GlobalButton(
                onTap: controller.onManageTap,
                text: 'Manage subscription',
                isOutlined: true,
              ),
            ],
            16.verticalSpace,
            AppText(
              'Payment will be charged to your Apple ID. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period.',
              textAlign: TextAlign.center,
              maxLines: 5,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.hintText,
                height: 1.45,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4FA3), Color(0xFF42C2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite_rounded, color: Colors.white, size: 36.sp),
          10.verticalSpace,
          AppText(
            'Lovelynk Premium',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          6.verticalSpace,
          AppText(
            'Stay close across any distance',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.isPremium,
    required this.isOnTrial,
    required this.trialDaysRemaining,
    required this.activePlan,
  });

  final bool isPremium;
  final bool isOnTrial;
  final int? trialDaysRemaining;
  final SubscriptionPlan? activePlan;

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle, color) = _statusContent();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                4.verticalSpace,
                AppText(
                  subtitle,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String, String, Color) _statusContent() {
    if (isPremium) {
      final planLabel = activePlan?.title ?? 'Premium';
      return (
        Icons.workspace_premium_rounded,
        'Premium active',
        'Your $planLabel plan is active. All widgets unlocked.',
        const Color(0xFFE8B923),
      );
    }
    if (isOnTrial) {
      final days = trialDaysRemaining ?? 0;
      return (
        Icons.timer_outlined,
        'Free trial active',
        '$days day${days == 1 ? '' : 's'} left. Subscribe before trial ends to keep widgets.',
        AppColor.secondary,
      );
    }
    return (
      Icons.lock_outline_rounded,
      'Widgets locked',
      'Start your one-time 7-day trial or subscribe to unlock all widgets.',
      AppColor.primary,
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.inputBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _RadioDot(isSelected: isSelected),
              14.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          plan.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        if (plan.badge != null) ...[
                          8.horizontalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryLight,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: AppText(
                              plan.badge!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    4.verticalSpace,
                    AppText(
                      plan.periodLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    if (plan.savingsLabel != null) ...[
                      4.verticalSpace,
                      AppText(
                        plan.savingsLabel!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppText(
                plan.formattedPrice,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColor.primary : AppColor.inputBorder,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  static const _features = [
    'All 12 home & lock screen widgets',
    'Unlimited customisation',
    'Real-time partner updates',
    'Heartbeat, Kiss & Emoji widgets',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'What you get',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          12.verticalSpace,
          for (final feature in _features) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18.sp,
                  color: AppColor.primary,
                ),
                10.horizontalSpace,
                Expanded(
                  child: AppText(
                    feature,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColor.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            10.verticalSpace,
          ],
        ],
      ),
    );
  }
}
