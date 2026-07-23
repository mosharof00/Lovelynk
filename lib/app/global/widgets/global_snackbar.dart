import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:get/get.dart';

import 'app_text.dart';

SnackbarController globalSnackBar({
  required String title,
  required String message,
  int? durationInSeconds,
  Color? titleColor,
  Color? backgroundColor,
  SnackPosition? snackPosition,
}) {
  final context = Get.context!;

  return Get.snackbar(
    '',
    '',
    titleText: AppText(
      title,
      style: context.titleSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: titleColor ?? Colors.white,
      ),
      textAlign: TextAlign.center,
    ),
    messageText: AppText(
      message,
      style: context.bodySmall.copyWith(color: Colors.white70),
      textAlign: TextAlign.center,
    ),
    backgroundColor: backgroundColor ?? Colors.black87,
    duration: Duration(seconds: durationInSeconds ?? 2),
    snackPosition: snackPosition ?? SnackPosition.TOP,
  );
}
