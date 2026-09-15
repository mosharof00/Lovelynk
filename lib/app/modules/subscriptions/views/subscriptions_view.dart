import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/utils/url_launcher.dart';
import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
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
      body: SafeArea(
        child: Obx(() {
          final state = controller.subscription.state.value;
          final selected =
              SubscriptionPlan.fromId(controller.selectedPlan.value) ??
              SubscriptionPlan.yearly;

          return Column(
            children: [
              const _TopBar(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                  children: [
                    const _Header(),
                    18.verticalSpace,
                    const _FeatureCards(),
                    18.verticalSpace,
                    const _FeatureChecklist(),
                    16.verticalSpace,
                    const _PartnerCallout(),
                    18.verticalSpace,
                    for (final plan in SubscriptionPlan.all) ...[
                      _PlanTile(
                        plan: plan,
                        isSelected: controller.selectedPlan.value == plan.id,
                        onTap: () => controller.selectPlan(plan.id),
                      ),
                      10.verticalSpace,
                    ],
                    if (state.isPremium) ...[
                      8.verticalSpace,
                      GlobalButton(
                        onTap: controller.onManageTap,
                        text: 'Manage subscription',
                        isOutlined: true,
                      ),
                    ],
                  ],
                ),
              ),
              if (!state.isPremium)
                _BottomCta(
                  plan: selected,
                  canStartTrial: controller.canStartTrial,
                  onPrimary: controller.canStartTrial
                      ? controller.startFreeTrial
                      : controller.subscribe,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 12.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close_rounded,
              size: 24.sp,
              color: AppColor.textPrimary,
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(AppConfig.appLogo, height: 90.w, width: 90.w),
            ),
          ),
          // TextButton(
          //   onPressed: Get.find<SubscriptionsController>().restorePurchases,
          //   child: AppText(
          //     'Restore',
          //     style: TextStyle(
          //       fontSize: 14.sp,
          //       fontWeight: FontWeight.w600,
          //       color: AppColor.primary.withValues(alpha: 0.75),
          //     ),
          //   ),
          // ),
          24.width,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          '${AppConfig.appName} Premium',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColor.textPrimary,
            height: 1.15,
          ),
        ),
        6.verticalSpace,
        AppText(
          'More ways to stay close',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColor.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HighlightCard(
            background: AppColor.primaryLight,
            icon: Align(
              alignment: Alignment.center,
              child: AppSvgIcon(
                Assets.icons.loveIcon,
                size: 32.w,
                color: AppColor.primary,
              ),
            ),
            title: 'Distance',
            subtitle: 'See how far apart you are',
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: _HighlightCard(
            background: const Color(0xFFF3E8FF),
            icon: Align(
              alignment: Alignment.center,
              child: AppSvgIcon(
                Assets.icons.kissIcon,
                size: 32.w,
                color: AppColor.primary,
              ),
            ),
            title: 'Kiss',
            subtitle: 'Send love anytime',
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: _HighlightCard(
            background: const Color(0xFFDDF4FF),
            icon: Align(
              alignment: Alignment.center,
              child: AppSvgIcon(
                Assets.icons.happyEmojiIcon,
                size: 36.w,
                color: AppColor.secondary,
              ),
            ),
            title: 'Mood',
            subtitle: "See how they're feeling",
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.background,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color background;
  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108.h,
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const Spacer(),
          AppText(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),
          2.verticalSpace,
          AppText(
            subtitle,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChecklist extends StatelessWidget {
  const _FeatureChecklist();

  static const _left = [
    'All 12 home & lock screen widgets',
    'Kiss, Heartbeat & Emoji widgets',
    'Real-time partner updates',
  ];

  static const _right = [
    'Unlimited customisation',
    'Exclusive themes & backgrounds',
    'One subscription for both of you ❤️',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ChecklistColumn(items: _left)),
        10.horizontalSpace,
        Expanded(child: _ChecklistColumn(items: _right)),
      ],
    );
  }
}

class _ChecklistColumn extends StatelessWidget {
  const _ChecklistColumn({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                margin: EdgeInsets.only(top: 1.h),
                decoration: const BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 12.sp,
                  color: Colors.white,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: AppText(
                  item,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          10.verticalSpace,
        ],
      ],
    );
  }
}

class _PartnerCallout extends StatelessWidget {
  const _PartnerCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColor.primaryLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          AppSvgIcon(
            Assets.icons.lovePartnerIcon,
            size: 28.sp,
            color: AppColor.primary,
          ),
          12.horizontalSpace,
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.35,
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(
                    text: 'One subscription. Your partner doesn\'t pay. ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text:
                        'When you subscribe, their account is activated too ❤️',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
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
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.inputBorder,
              width: isSelected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              _RadioDot(isSelected: isSelected),
              12.horizontalSpace,
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
                            fontWeight: FontWeight.w800,
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
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: AppText(
                              plan.badge!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    4.verticalSpace,
                    AppText(
                      plan.billingLine,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    2.verticalSpace,
                    AppText(
                      plan.perUserLine,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (plan.savingsLabel != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText(
                    plan.savingsLabel!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
          color: isSelected ? AppColor.primary : const Color(0xFFC8C4D0),
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

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.plan,
    required this.canStartTrial,
    required this.onPrimary,
  });

  final SubscriptionPlan plan;
  final bool canStartTrial;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final thenLine = canStartTrial
        ? 'Then ${plan.thenPriceLine}. Cancel anytime.'
        : '${plan.billingLine}. Cancel anytime.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: AppColor.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlobalButton(
            onTap: onPrimary,
            text: canStartTrial ? 'Start 7-day free trial' : 'Subscribe now',
          ),
          10.verticalSpace,
          AppText(
            thenLine,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColor.textSecondary),
          ),
          14.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: AppColor.inputBorder.withValues(alpha: 0.9),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegalLink(
                      label: 'Terms of Use',
                      onTap: () => UrlLauncher.url(
                        'https://flutter.pixelstack.cloud/terms',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: AppText(
                        '·',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.hintText,
                        ),
                      ),
                    ),
                    _LegalLink(
                      label: 'Privacy Policy',
                      onTap: () => UrlLauncher.url(
                        'https://flutter.pixelstack.cloud/privacy',
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Divider(
                  color: AppColor.inputBorder.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AppText(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColor.hintText,
        ),
      ),
    );
  }
}
