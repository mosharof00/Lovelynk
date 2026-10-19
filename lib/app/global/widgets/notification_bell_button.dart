import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/services/push_notification_service.dart';
import '../../core/theme/app_color.dart';
import '../../routes/app_pages.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// Shared notification bell used on Home / Widgets headers with unread badge.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 20.sp;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.inputBorder.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AppSvgIcon(
              Assets.icons.notificationIcon,
              size: iconSize,
              color: AppColor.secondary,
            ),
          ),
          Obx(() {
            if (!Get.isRegistered<PushNotificationService>()) {
              return const SizedBox.shrink();
            }
            final count = PushNotificationService.to.unreadCount.value;
            if (count <= 0) return const SizedBox.shrink();

            final label = count > 99 ? '99+' : '$count';
            return Positioned(
              top: -2.h,
              right: -2.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: count > 9 ? 4.5.w : 5.w,
                  vertical: 2.h,
                ),
                constraints: BoxConstraints(
                  minWidth: 16.w,
                  minHeight: 16.w,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColor.white,
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: AppText(
                  label,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.white,
                    height: 1.1,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
