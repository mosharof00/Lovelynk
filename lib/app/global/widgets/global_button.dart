import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_text.dart';

class GlobalButton extends StatelessWidget {
  const GlobalButton({
    super.key,
    required this.onTap,
    required this.text,
    this.color,
    this.borderColor,
    this.textColor,
    this.height,
    this.width,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.gradient,
    this.boxShadow,
    this.suffixWidget,
    this.prefixWidget,
    this.padding,
    this.isDisabled = false,
    this.widget,
    this.textStyle,
    this.isOutlined = false,
  });

  final VoidCallback onTap;
  final String text;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final Widget? widget;
  final EdgeInsetsGeometry? padding;
  final bool isDisabled;
  final TextStyle? textStyle;
  final bool isOutlined;

  Color _resolveColor() {
    if (isDisabled) return AppColor.primaryDisable;
    if (isOutlined) return Colors.transparent;
    return color ?? AppColor.primary;
  }

  Color _resolveTextColor() {
    if (isOutlined) return textColor ?? AppColor.primary;
    return textColor ?? AppColor.white;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = height ?? 48.h;
    final resolvedRadius =
        borderRadius ?? BorderRadius.circular(resolvedHeight / 2);

    return CupertinoButton(
      onPressed: isDisabled ? null : onTap,
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        height: resolvedHeight,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: gradient == null ? _resolveColor() : null,
          gradient: isDisabled ? null : gradient,
          borderRadius: resolvedRadius,
          border: Border.all(
            color: borderColor ??
                (isOutlined ? AppColor.primary : Colors.transparent),
            width: isOutlined ? 1.5 : 1,
          ),
          boxShadow: isDisabled ? null : boxShadow,
        ),
        child: widget ??
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ?prefixWidget,
                Expanded(
                  child: AppText(
                    text,
                    style: textStyle ??
                        context.titleSmall.copyWith(
                          color: _resolveTextColor(),
                          fontSize: fontSize ?? 15.sp,
                          fontWeight: fontWeight ?? FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ?suffixWidget,
              ],
            ),
      ),
    );
  }
}
