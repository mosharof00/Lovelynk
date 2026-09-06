import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/widget_preview_assets.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/models/widget_models/widget_style.dart';
import '../../../global/widgets/app_text.dart';
import '../../widgets/widgets/renderers/widget_accent_scope.dart';
import '../../widgets/widgets/renderers/widget_body_builder.dart';

/// Customise preview: home-screen wallpaper + live widget body
/// (same renderers as the Widgets tab / native home layout).
class CustomiseHomePreview extends StatelessWidget {
  const CustomiseHomePreview({
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
    return SizedBox(
      width: WidgetPreviewAssets.previewLogicalWidth.w,
      height: WidgetPreviewAssets.previewLogicalHeight.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _HomePreviewBackground(),
            // Soft vignette so the widget card reads clearly.
            Container(color: Colors.black.withValues(alpha: 0.08)),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Home Screen preview',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _HomeWidgetCard(
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

class _HomePreviewBackground extends StatelessWidget {
  const _HomePreviewBackground();

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

class _HomeWidgetCard extends StatelessWidget {
  const _HomeWidgetCard({
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
    final isWide = widget.isWide;
    final cardWidth = isWide ? 220.w : 128.w;
    final cardHeight = isWide ? 110.h : 128.h;
    final titleSize = switch (style.textSize) {
      WidgetTextSize.small => 10.sp,
      WidgetTextSize.medium => 11.sp,
      WidgetTextSize.large => 12.sp,
    };

    return WidgetAccentScope(
      accent: themeColor,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: style.font.fontFamily),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
          decoration: BoxDecoration(
            color: style.useBackground
                ? backgroundColor.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18.r),
            border: style.useBackground
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                widget.title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: style.useBackground
                      ? AppColor.textPrimary
                      : Colors.white,
                  fontFamily: style.font.fontFamily,
                ),
              ),
              4.verticalSpace,
              Expanded(
                child: Center(child: buildWidgetBody(widget.type)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
