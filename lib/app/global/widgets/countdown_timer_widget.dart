import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_text.dart';

class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({super.key, required this.expireDate});

  final DateTime expireDate;

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateDuration();
    _startTimer();
  }

  void _calculateDuration() {
    final now = DateTime.now();
    _duration = widget.expireDate.isAfter(now)
        ? widget.expireDate.difference(now)
        : Duration.zero;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _calculateDuration();
        if (_duration.inSeconds <= 0) _timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_duration.inSeconds <= 0) return const SizedBox.shrink();

    String pad(int n) => n.toString().padLeft(2, '0');
    final days = _duration.inDays;
    final hours = pad(_duration.inHours.remainder(24));
    final minutes = pad(_duration.inMinutes.remainder(60));
    final seconds = pad(_duration.inSeconds.remainder(60));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (days > 0) ...[
          _TimeBox(value: days.toString(), label: 'Days', context: context),
          _Separator(context: context),
        ],
        _TimeBox(value: hours, label: 'Hrs', context: context),
        _Separator(context: context),
        _TimeBox(value: minutes, label: 'Min', context: context),
        _Separator(context: context),
        _TimeBox(value: seconds, label: 'Sec', context: context),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.value,
    required this.label,
    required this.context,
  });

  final String value;
  final String label;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            value,
            style: context.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColor.primary,
            ),
          ),
          2.width,
          AppText(
            label,
            style: context.labelSmall.copyWith(
              fontSize: 8.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: AppText(
        ':',
        style: context.labelSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColor.primary,
        ),
      ),
    );
  }
}
