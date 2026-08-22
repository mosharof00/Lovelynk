import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../../../routes/app_pages.dart';

class HomeHowToTips extends StatelessWidget {
  const HomeHowToTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'How to add widget',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          4.verticalSpace,
          AppText(
            'Choose your screen to see step-by-step instructions.',
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
          14.verticalSpace,
          _HowToRow(
            imagePath: Assets.images.lockScreenDemo.path,
            title: 'Lock Screen',
            body:
                'See how to add ${AppConfig.appName} widgets to your lock screen.',
            onTap: () => Get.toNamed(Routes.LOCK_SCREEN_GUID),
          ),
          12.verticalSpace,
          _HowToRow(
            imagePath: Assets.images.homeScreenDemo.path,
            title: 'Home Screen',
            body:
                'See how to add ${AppConfig.appName} widgets to your home screen.',
            onTap: () => Get.toNamed(Routes.HOME_SCREEN_GUID),
          ),
        ],
      ),
    );
  }
}

class _HowToRow extends StatelessWidget {
  const _HowToRow({
    required this.imagePath,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              imagePath,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.cover,
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                4.verticalSpace,
                AppText(
                  body,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColor.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
