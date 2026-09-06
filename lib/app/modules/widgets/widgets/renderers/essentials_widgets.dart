import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/widget_data_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import 'widget_common.dart';
import 'widget_accent_scope.dart';

WidgetDataService get _service => Get.find<WidgetDataService>();

// ── Partner Distance (full width, animated J ♥ M) ───────────────────

class PartnerDistanceWidget extends StatelessWidget {
  const PartnerDistanceWidget({super.key});

  /// Distance (miles) at which the dots are fully stretched apart.
  static const double _maxMiles = 500;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _service.data.value;
      // t = 1 when together (dots closed), 0 when far apart (dots stretched).
      final t = (1 - (data.distanceMiles / _maxMiles)).clamp(0.0, 1.0);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            'Our distance: ${data.distanceMiles} miles',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
            ),
          ),
          16.verticalSpace,
          SizedBox(
            height: 36.w,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Animate smoothly whenever the distance (t) changes.
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  tween: Tween<double>(end: t),
                  builder: (context, animT, _) {
                    return _DistanceTrack(
                      width: constraints.maxWidth,
                      t: animT,
                      userInitial: data.userInitial,
                      partnerInitial: data.partnerInitial,
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _DistanceTrack extends StatelessWidget {
  const _DistanceTrack({
    required this.width,
    required this.t,
    required this.userInitial,
    required this.partnerInitial,
  });

  final double width;
  final double t;
  final String userInitial;
  final String partnerInitial;

  @override
  Widget build(BuildContext context) {
    final diameter = 34.w;
    final radius = diameter / 2;
    final heartHalf = 13.w;
    final centerX = width / 2;
    final centerY = 18.w;

    // Closest the user circle centre can sit next to the heart.
    final userMin = centerX - heartHalf - 8.w - radius;
    final userX = radius + (userMin - radius) * t;
    final partnerX = width - userX;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dots ONLY in the two gaps: user↔heart and heart↔partner.
        Positioned.fill(
          child: CustomPaint(
            painter: _DistanceDotsPainter(
              y: centerY,
              leftStart: userX + radius + 5.w,
              leftEnd: centerX - heartHalf - 5.w,
              rightStart: centerX + heartHalf + 5.w,
              rightEnd: partnerX - radius - 5.w,
              color: AppColor.primaryDisable,
            ),
          ),
        ),
        Positioned(
          left: centerX - heartHalf,
          top: centerY - heartHalf,
          child:
          AppSvgIcon(Assets.icons.loveDoubleIcon, size:  heartHalf * 2.3, color: WidgetAccentScope.of(context)),

          // Icon(
          //   Icons.favorite_rounded,
          //   color: WidgetAccentScope.of(context),
          //   size: heartHalf * 2,
          // ),
        ),
        Positioned(
          left: userX - radius,
          top: centerY - radius,
          child: _PersonDot(label: userInitial, size: diameter),
        ),
        Positioned(
          left: partnerX - radius,
          top: centerY - radius,
          child: _PersonDot(label: partnerInitial, size: diameter),
        ),
      ],
    );
  }
}

class _PersonDot extends StatelessWidget {
  const _PersonDot({required this.label, required this.size});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColor.white,
        shape: BoxShape.circle,
        border: Border.all(color: WidgetAccentScope.of(context), width: 1.5),
      ),
      alignment: Alignment.center,
      child: AppText(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: WidgetAccentScope.of(context),
        ),
      ),
    );
  }
}

class _DistanceDotsPainter extends CustomPainter {
  _DistanceDotsPainter({
    required this.y,
    required this.leftStart,
    required this.leftEnd,
    required this.rightStart,
    required this.rightEnd,
    required this.color,
  });

  final double y;
  final double leftStart;
  final double leftEnd;
  final double rightStart;
  final double rightEnd;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    _dots(canvas, paint, leftStart, leftEnd);
    _dots(canvas, paint, rightStart, rightEnd);
  }

  void _dots(Canvas canvas, Paint paint, double start, double end) {
    if (end <= start) return;
    const spacing = 7.0;
    const dotRadius = 1.6;
    for (double x = start; x <= end; x += spacing) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DistanceDotsPainter old) {
    return old.leftStart != leftStart ||
        old.leftEnd != leftEnd ||
        old.rightStart != rightStart ||
        old.rightEnd != rightEnd ||
        old.y != y ||
        old.color != color;
  }
}

// ── Days Together ───────────────────────────────────────────────────

class DaysTogetherWidget extends StatelessWidget {
  const DaysTogetherWidget({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final days = _service.data.value.daysTogether;
      final content = Column(
        mainAxisAlignment: compact
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          AppSvgIcon(
            Assets.icons.loveIcon,
            size: compact ? 18.sp : 24.sp,
            color: WidgetAccentScope.of(context),
          ),
          if (!compact) SizedBox(height: 8.h),
          AppText(
            '$days',
            style: TextStyle(
              fontSize: compact ? 18.sp : 24.sp,
              fontWeight: FontWeight.w700,
              color: WidgetAccentScope.of(context),
              height: 1.0,
            ),
          ),
          if (!compact) SizedBox(height: 6.h),
          AppText(
            'days',
            style: TextStyle(
              fontSize: compact ? 10.sp : 12.sp,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      );
      return compact ? SizedBox.expand(child: content) : content;
    });
  }
}

// ── Together Counter (live) ─────────────────────────────────────────

class TogetherCounterWidget extends StatelessWidget {
  const TogetherCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final now = _service.now.value;
      final since = _service.data.value.togetherSince;
      return CountdownRow(duration: now.difference(since));
    });
  }
}

// ── Partner Time (live) ─────────────────────────────────────────────

class PartnerTimeWidget extends StatelessWidget {
  const PartnerTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _service.data.value;
      final time = data.partnerTime(_service.now.value);
      final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '$hour12:$minute',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  color: WidgetAccentScope.of(context),
                  height: 1.0,
                ),
              ),
              4.horizontalSpace,
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: AppText(
                  period,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: WidgetAccentScope.of(context),
                  ),
                ),
              ),
            ],
          ),
          8.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 12.sp,
                color: AppColor.textSecondary,
              ),
              2.horizontalSpace,
              Flexible(
                child: AppText(
                  data.partnerCity,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ── Partner Weather ─────────────────────────────────────────────────

class PartnerWeatherWidget extends StatelessWidget {
  const PartnerWeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weather = _service.data.value.partnerWeather;
      final city = _service.data.value.partnerCity;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppSvgIcon(
                weather.iconPath,
                size: 36.sp,
                // color: WidgetAccentScope.of(context),
              ),
              10.horizontalSpace,
              AppText(
                '${weather.temperature}°',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: WidgetAccentScope.of(context),
                  height: 1.0,
                ),
              ),
            ],
          ),
          6.verticalSpace,
          AppText(
            weather.condition,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: WidgetAccentScope.of(context),
            ),
          ),
          2.verticalSpace,
          AppText(
            city,
            maxLines: 1,
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }
}

// ── Next Visit Countdown (live) ─────────────────────────────────────

class NextVisitCountdownWidget extends StatelessWidget {
  const NextVisitCountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final now = _service.now.value;
      final nextVisit = _service.data.value.nextVisit;
      return CountdownRow(duration: nextVisit.difference(now));
    });
  }
}
