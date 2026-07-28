import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class HomeAffirmationCard extends GetView<HomeController> {
  const HomeAffirmationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.inputBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Daily Affirmation',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
          8.verticalSpace,
          Obx(
            () => AppText(
              controller.affirmation.value,
              maxLines: 4,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
                height: 1.35,
              ),
            ),
          ),
          8.verticalSpace,
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 12.sp, color: AppColor.primary),
              4.horizontalSpace,
              Icon(Icons.favorite_rounded, size: 12.sp, color: AppColor.primaryLight),
              4.horizontalSpace,
              Icon(Icons.favorite_rounded, size: 12.sp, color: AppColor.primary),
            ],
          ),
        ],
      ),
    );
  }
}
