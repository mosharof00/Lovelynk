import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import 'widget_accent_scope.dart';

/// A 2-row D : H / M : S countdown/counter grid (Together Counter + Next Visit),
/// styled to match the Home and Lock Screen widgets.
///
/// Upper row: Day & Hour
/// Lower row: Min & Sec
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Upper row: Day & Hour
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Unit(
                    value: days,
                    label: 'DAY',
                    color: valueColor,
                    pad: false,
                  ),
                  _Colon(color: valueColor),
                  _Unit(
                    value: hours,
                    label: 'HOUR',
                    color: valueColor,
                  ),
                ],
              ),
              6.verticalSpace,
              // Lower row: Min & Sec
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Unit(
                    value: minutes,
                    label: 'MIN',
                    color: valueColor,
                  ),
                  _Colon(color: valueColor),
                  _Unit(
                    value: seconds,
                    label: 'SEC',
                    color: valueColor,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({
    required this.value,
    required this.label,
    required this.color,
    this.pad = true,
  });

  final int value;
  final String label;
  final Color color;
  final bool pad;

  @override
  Widget build(BuildContext context) {
    final text = pad ? value.toString().padLeft(2, '0') : value.toString();
    return SizedBox(
      width: 48.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
          3.verticalSpace,
          AppText(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14.w,
      height: 22.sp,
      child: Center(
        child: AppText(
          ':',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
