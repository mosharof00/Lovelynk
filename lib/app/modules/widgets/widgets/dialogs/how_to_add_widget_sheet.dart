import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../routes/app_pages.dart';

/// Bottom sheet: choose Lock Screen or Home Screen setup slides.
class HowToAddWidgetSheet extends StatelessWidget {
  const HowToAddWidgetSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const HowToAddWidgetSheet(),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _openGuide(String route) {
    Get.back();
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final name = AppConfig.appName;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColor.inputBorder,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            20.verticalSpace,
            AppText(
              'How to add widget',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            6.verticalSpace,
            AppText(
              'Choose your screen to see step-by-step instructions.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary,
                height: 1.35,
              ),
            ),
            20.verticalSpace,
            _HowToRow(
              imagePath: Assets.images.lockScreenDemo.path,
              title: 'Lock Screen',
              body: 'See how to add $name widgets to your lock screen.',
              onTap: () => _openGuide(Routes.LOCK_SCREEN_GUIDE),
            ),
            14.verticalSpace,
            _HowToRow(
              imagePath: Assets.images.homeScreenDemo.path,
              title: 'Home Screen',
              body: 'See how to add $name widgets to your home screen.',
              onTap: () => _openGuide(Routes.HOME_SCREEN_GUIDE),
            ),
          ],
        ),
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
            borderRadius: BorderRadius.circular(14.r),
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                4.verticalSpace,
                AppText(
                  body,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: AppColor.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}
