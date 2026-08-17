import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Frosted-glass card. Must sit *above* a textured / coloured layer
/// (use [GlassBackground] in a [Stack]) or the blur has nothing to sample.
///
/// ```dart
/// GlassCard(
///   padding: EdgeInsets.all(16.w),
///   child: Text('Content'),
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.onTap,
    this.blurSigma = 24,
    this.opacity = 0.28,
    this.borderOpacity = 0.7,
    this.showShadow = true,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  /// Backdrop blur strength.
  final double blurSigma;

  /// White fill opacity. Keep low so the background shows through.
  final double opacity;

  final double borderOpacity;
  final bool showShadow;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(22.r);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0077B6).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity + 0.08),
                  Colors.white.withValues(alpha: opacity),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}
