import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/widget_preview_assets.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/models/widget_models/widget_style.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/app_text.dart';

class CustomiseLockPreview extends StatelessWidget {
  const CustomiseLockPreview({
    super.key,
    required this.widget,
    required this.style,
    required this.themeColor,
    required this.backgroundColor,
  });

  final WidgetDefinition widget;
  final WidgetStyle style;
  final Color themeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final timeText =
        '${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')}';

    return SizedBox(
      width: WidgetPreviewAssets.previewLogicalWidth.w,
      height: WidgetPreviewAssets.previewLogicalHeight.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _PreviewBackground(),
            Container(color: Colors.black.withValues(alpha: 0.15)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                children: [
                  AppText(
                    'Monday 21 July',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppText(
                    timeText,
                    style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _WidgetPreviewChip(
                      widget: widget,
                      style: style,
                      themeColor: themeColor,
                      backgroundColor: backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBackground extends StatelessWidget {
  const _PreviewBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      WidgetPreviewAssets.lockPreviewBg,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8B4D4),
              Color(0xFFB8A4E8),
              Color(0xFF9BB7F0),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetPreviewChip extends StatelessWidget {
  const _WidgetPreviewChip({
    required this.widget,
    required this.style,
    required this.themeColor,
    required this.backgroundColor,
  });

  final WidgetDefinition widget;
  final WidgetStyle style;
  final Color themeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.textSize.previewFontSize.sp;
    final family = style.font.fontFamily;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: style.useBackground
            ? backgroundColor.withValues(alpha: 0.92)
            : Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(widget.icon, color: themeColor, size: 18.sp),
          8.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                widget.previewValue,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                  fontFamily: family,
                  height: 1.1,
                ),
              ),
              AppText(
                widget.previewUnit,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: style.useBackground
                      ? Colors.white.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.9),
                  fontFamily: family,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
