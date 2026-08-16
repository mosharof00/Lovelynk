import 'package:bulkretail/app/core/theme/app_gradient.dart';
import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class HomeRecentActivity extends GetView<HomeController> {
  const HomeRecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = controller.isConnected.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColor.inputBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                const Spacer(),
                if (connected)
                  AppText(
                    'View all',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            16.verticalSpace,
            if (!connected)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Column(
                    children: [
                      Container(
                        width: 65.w,
                        decoration: BoxDecoration(
                          gradient: AppGradient.brand,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: AppSvgIcon(
                            Assets.icons.emailFillIcon,
                            color: Colors.white,
                            size: 55.w,
                          ),
                        ),
                      ),
                      8.verticalSpace,
                      AppText(
                        'No activity yet',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      4.verticalSpace,
                      AppText(
                        'Connect with your partner to start sharing moments.',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColor.hintText,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  _ActivityRow(
                    text: '${controller.partnerName.value} sent you 3 kisses',
                    time: '2m ago',
                  ),
                  _ActivityRow(
                    text:
                        'You held ${controller.partnerName.value}\'s heartbeat',
                    time: '1h ago',
                  ),
                  _ActivityRow(
                    text:
                        '${controller.partnerName.value} checked your compass',
                    time: '3h ago',
                    showDivider: false,
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.text,
    required this.time,
    this.showDivider = true,
  });

  final String text;
  final String time;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: AppText(
                text,
                maxLines: 2,
                style: TextStyle(fontSize: 12.sp, color: AppColor.textPrimary),
              ),
            ),
            AppText(
              time,
              style: TextStyle(fontSize: 10.sp, color: AppColor.hintText),
            ),
          ],
        ),
        if (showDivider) ...[
          10.verticalSpace,
          Divider(
            height: 1,
            color: AppColor.inputBorder.withValues(alpha: 0.6),
          ),
          10.verticalSpace,
        ],
      ],
    );
  }
}
