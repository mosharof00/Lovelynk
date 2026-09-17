import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/services/subscription_service.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/flying_hearts_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

/// Thin Couples-Joy-style PRO banner with hearts rising bottom → top.
class ProfileSubscriptionBanner extends StatelessWidget {
  const ProfileSubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Get.find<SubscriptionService>();

    return Obx(() {
      if (subscription.state.value.isPremium) {
        return const SizedBox.shrink();
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.SUBSCRIPTIONS),
          borderRadius: BorderRadius.circular(18.r),
          child: Ink(
            height: 72.h,
            decoration: BoxDecoration(
              color: AppColor.primaryLight,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const FlyingHeartsBackground(color: AppColor.primary),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      AppConfig.appName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColor.textPrimary,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  6.horizontalSpace,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'PRO',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              4.verticalSpace,
                              Text(
                                'Unlock all widgets & premium features',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColor.textSecondary,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        10.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColor.primary.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'BUY NOW',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              2.horizontalSpace,
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16.sp,
                                color: AppColor.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
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
