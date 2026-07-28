import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'Good morning,',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
                AppText(
                  controller.userName.value,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColor.primaryLight,
            child: Icon(Icons.person_rounded, color: AppColor.primary, size: 24.sp),
          ),
        ],
      ),
    );
  }
}
