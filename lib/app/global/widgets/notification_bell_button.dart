import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_color.dart';
import '../../routes/app_pages.dart';
import 'app_svg_icon.dart';

/// Shared notification bell used on Home / Widgets headers.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 20.sp;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
    );
  }
}
