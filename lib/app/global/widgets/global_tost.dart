import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'app_text.dart';

void globalToast({
  required String message,
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  int? durationInSeconds,
  double? borderRadius,
  EdgeInsets? margin,
  SnackPosition? position,
}) {
  final context = Get.context!;

  Get.rawSnackbar(
    messageText: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor ?? Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: AppText(
            message,
            style: context.bodySmall.copyWith(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor ?? Colors.black87,
    borderRadius: borderRadius ?? 12.r,
    margin: margin ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
    snackPosition: position ?? SnackPosition.BOTTOM,
    duration: Duration(seconds: durationInSeconds ?? 2),
    animationDuration: const Duration(milliseconds: 300),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}