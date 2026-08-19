import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/widget_data_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';

WidgetDataService get _service => Get.find<WidgetDataService>();

// ── Love Compass ────────────────────────────────────────────────────

class LoveCompassWidget extends StatelessWidget {
  const LoveCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _service.data.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55.w,
            height: 55.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primaryDisable, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: data.compassBearing * math.pi / 180,
              child: Icon(
                Icons.navigation_rounded,
                color: AppColor.primary,
                size: 28.sp,
              ),
            ),
          ),
          4.verticalSpace,
          AppText(
            '${data.compassMiles} miles',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          2.verticalSpace,
          AppText(
            'this way',
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }
}

// ── Initials (J ♥ M) ────────────────────────────────────────────────

class InitialsWidget extends StatelessWidget {
  const InitialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _service.data.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InitialCircle(label: data.userInitial),
          8.horizontalSpace,
          Icon(Icons.favorite_rounded, color: AppColor.primary, size: 20.sp),
          8.horizontalSpace,
          _InitialCircle(label: data.partnerInitial),
        ],
      );
    });
  }
}

class _InitialCircle extends StatelessWidget {
  const _InitialCircle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.primary, width: 1.5),
      ),
      alignment: Alignment.center,
      child: AppText(
        label,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColor.primary,
        ),
      ),
    );
  }
}

// ── Anniversary ─────────────────────────────────────────────────────

class AnniversaryWidget extends StatelessWidget {
  const AnniversaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final anniversary = _service.data.value.anniversary;
      final dateText = DateFormat('d MMM yyyy').format(anniversary);
      final daysToGo = _daysToNext(anniversary);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            dateText,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          6.verticalSpace,
          AppText(
            '$daysToGo days to go',
            style: TextStyle(fontSize: 12.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }

  /// Days until the next occurrence of this month/day.
  int _daysToNext(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = DateTime(today.year, date.month, date.day);
    if (next.isBefore(today)) {
      next = DateTime(today.year + 1, date.month, date.day);
    }
    return next.difference(today).inDays;
  }
}
