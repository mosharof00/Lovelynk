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

  Color _resolveColor() {
    if (isDisabled) return AppColor.primaryDisable;
    return color ?? AppColor.primary;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: isDisabled ? null : onTap,
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        height: height ?? 45.h,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: gradient == null ? _resolveColor() : null,
          gradient: isDisabled ? null : gradient,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          border: Border.all(color: borderColor ?? Colors.transparent),
          boxShadow: isDisabled ? null : boxShadow,
        ),
        child:
            widget ??
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ?prefixWidget,
                Expanded(
                  child: AppText(
                    text,
                    style:
                        textStyle ??
                        context.titleSmall.copyWith(
                          color: textColor ?? Colors.white,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
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
