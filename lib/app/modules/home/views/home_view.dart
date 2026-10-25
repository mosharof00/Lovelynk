import 'package:bulkretail/app/global/animations/fade_in_animation.dart';
import 'package:bulkretail/app/modules/home/widgets/not_connected_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_affirmation_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_how_to_tips.dart';
import '../widgets/home_recent_activity.dart';
import '../widgets/home_widgets_row.dart';
import '../widgets/partner_distance_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              const HomeHeader(),
              const _OfflineBanner(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: controller.onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.verticalSpace,
                        FadeInAnimation(
                          delay: 1,
                          shouldAnimate: controller.isFadeInAnimate,
                          child: PartnerDistanceCard(),
                        ),
                        FadeInAnimation(
                          delay: 2,
                          shouldAnimate: controller.isFadeInAnimate,
                          child: NotConnectedCard(),
                        ),
                        12.verticalSpace,
                        FadeInAnimation(
                          delay: controller.isConnected.value ? 2 : 3,
                          shouldAnimate: controller.isFadeInAnimate,
                          child: const HomeWidgetsRow(),
                        ),
                        12.verticalSpace,
                        FadeInAnimation(
                          delay: controller.isConnected.value ? 3 : 4,
                          shouldAnimate: controller.isFadeInAnimate,
                          child: HomeAffirmationCard(),
                        ),
                        12.verticalSpace,
                        FadeInAnimation(
                          delay: controller.isConnected.value ? 4 : 5,
                          shouldAnimate: controller.isFadeInAnimate,
                          child: const HomeRecentActivity(),
                        ),
                        20.verticalSpace,
                        const HomeHowToTips(),
                        16.verticalSpace,
                      ],
                    ),
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

class _OfflineBanner extends GetView<HomeController> {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isOffline.value) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Material(
          color: AppColor.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: controller.onRefresh,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 18.sp,
                    color: AppColor.error,
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: AppText(
                      "Can't reach LoveLynk. Showing saved info.",
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.error,
                      ),
                    ),
                  ),
                  AppText(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
