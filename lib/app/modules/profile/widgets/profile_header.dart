import 'package:bulkretail/app/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/cached_image.dart';
import '../controllers/profile_controller.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Get.find<SubscriptionService>();

    return Obx(
      () {
        final isPremium = subscription.state.value.isPremium;

        return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        child: InkWell(
          onTap: controller.onProfileTap,
          borderRadius: BorderRadius.circular(22.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                CachedImage(
                  imgUrl: HelperUtils.demoProfileImage,
                  height: 70.w,
                  width: 70.w,
                  borderRadius: 50.r,
                ),
                14.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              controller.userName.value,
                              style: context.headlineMedium.copyWith(
                                color: AppColor.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPremium) ...[
                            6.horizontalSpace,
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 20.sp,
                              color: const Color(0xFFE8B923),
                            ),
                          ],
                        ],
                      ),
                      if (isPremium) ...[
                        6.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondary,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24.sp,
                  color: AppColor.hintText,
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}
