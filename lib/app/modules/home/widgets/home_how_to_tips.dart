import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';

class HomeHowToTips extends StatelessWidget {
  const HomeHowToTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          'Choose your screen for step-by-step instructions.',
          style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
        ),
        12.verticalSpace,
        Row(
          children: [
            Expanded(
              child: _TipCard(
                title: 'Lock Screen',
                body: 'See how to add Lovelynk widgets to your lock screen.',
                icon: Icons.lock_outline_rounded,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: _TipCard(
                title: 'Home Screen',
                body: 'See how to add Lovelynk widgets to your home screen.',
                icon: Icons.home_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.inputBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              color: AppColor.background2,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColor.primary, size: 22.sp),
          ),
          8.verticalSpace,
          AppText(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          4.verticalSpace,
          AppText(
            body,
            maxLines: 3,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColor.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
