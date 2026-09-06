import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import 'widget_accent_scope.dart';

/// A D : H : M : S countdown/counter row (Together Counter + Next Visit).
///
/// Pass the already-computed [duration]; negative values clamp to zero. Only
/// the caller decides when to rebuild (wrap in a small Obx over `now`).
class CountdownRow extends StatelessWidget {
  const CountdownRow({super.key, required this.duration, this.color});

  final Duration duration;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final d = duration.isNegative ? Duration.zero : duration;
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final valueColor = color ?? WidgetAccentScope.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Unit(value: days, label: 'DAY', color: valueColor),
        _Colon(color: valueColor),
        _Unit(value: hours, label: 'HOUR', color: valueColor),
        _Colon(color: valueColor),
        _Unit(value: minutes, label: 'MIN', color: valueColor),
        _Colon(color: valueColor),
        _Unit(value: seconds, label: 'SEC', color: valueColor),
      ],
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.0,
          ),
        ),
        2.verticalSpace,
        AppText(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: AppText(
        ':',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }
}
