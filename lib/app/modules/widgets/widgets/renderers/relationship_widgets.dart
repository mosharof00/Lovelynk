import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/compass_service.dart';
import '../../../../core/services/widget_data_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import 'widget_accent_scope.dart';

WidgetDataService get _service => Get.find<WidgetDataService>();
CompassService get _compass => Get.find<CompassService>();

// ── Love Compass (live heading + partner bearing) ───────────────────

class LoveCompassWidget extends StatelessWidget {
  const LoveCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _service.data.value;
      final miles = _compass.hasLocation.value
          ? _compass.partnerMiles.value
          : data.compassMiles;
      final radians = _compass.needleRadians();
      final partnerLabel = data.partnerName.trim().split(' ').first;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompassDial(needleRadians: radians),
          AppText(
            '$miles miles',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: WidgetAccentScope.of(context),
            ),
          ),

          AppText(
            '$partnerLabel is this way',
            maxLines: 1,
            style: TextStyle(fontSize: 8.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.needleRadians});

  final double needleRadians;

  static const _labels = ['N', 'E', 'S', 'W'];

  @override
  Widget build(BuildContext context) {
    final dialSize = 66.w;
    final ringSize = 52.w;

    return SizedBox(
      width: dialSize,
      height: dialSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: ringSize,
            height: ringSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: WidgetAccentScope.of(context), width: 1.5),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: _CardinalLabel(_labels[0])),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(child: _CardinalLabel(_labels[1])),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(child: _CardinalLabel(_labels[2])),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(child: _CardinalLabel(_labels[3])),
          ),
          Transform.rotate(
            angle: needleRadians,
            child: Icon(
              Icons.navigation_rounded,
              color: WidgetAccentScope.of(context),
              size: 28.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardinalLabel extends StatelessWidget {
  const _CardinalLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppText(
      label,
      style: TextStyle(
        fontSize: 8.sp,
        fontWeight: FontWeight.w600,
        color: WidgetAccentScope.of(context),
        height: 1.0,
      ),
    );
  }
}

// ── Initials (J ♥ M) ────────────────────────────────────────────────

class InitialsWidget extends StatelessWidget {
  const InitialsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _service.data.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _InitialCircle(label: data.userInitial),
                8.horizontalSpace,
                Icon(
                  Icons.favorite_rounded,
                  color: WidgetAccentScope.of(context),
                  size: 20.sp,
                ),
                8.horizontalSpace,
                _InitialCircle(label: data.partnerInitial),
              ],
            ),
          );
        },
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
        border: Border.all(color: WidgetAccentScope.of(context), width: 1.5),
      ),
      alignment: Alignment.center,
      child: AppText(
        label,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: WidgetAccentScope.of(context),
        ),
      ),
    );
  }
}

// ── Anniversary ─────────────────────────────────────────────────────

class AnniversaryWidget extends StatelessWidget {
  const AnniversaryWidget({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final anniversary = _service.data.value.anniversary;
      final day = DateFormat('d').format(anniversary);
      final month = DateFormat('MMM').format(anniversary);
      final year = DateFormat('yyyy').format(anniversary);
      final daysToGo = _daysToNext(anniversary);

      final dateStyle = TextStyle(
        fontSize: compact ? 14.sp : 20.sp,
        fontWeight: FontWeight.w700,
        color: WidgetAccentScope.of(context),
        height: 1.05,
      );

      final content = Column(
        mainAxisAlignment: compact
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Vertical stack: day / month / year
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(day, textAlign: TextAlign.center, style: dateStyle),
              AppText(month, textAlign: TextAlign.center, style: dateStyle),
              AppText(year, textAlign: TextAlign.center, style: dateStyle),
            ],
          ),
          if (!compact) SizedBox(height: 6.h),
          AppText(
            '$daysToGo days to go',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 9.sp : 12.sp,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      );
      return compact ? SizedBox.expand(child: content) : content;
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
