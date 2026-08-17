import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_color.dart';

/// Light liquid-glass backdrop (`AppColor.background`). Place behind
/// [GlassCard] in a [Stack] so the frost has colour to sample.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, this.child});

  final Widget? child;

  static  Color base = AppColor.background;
  // static  Color base = Colors.grey.shade200;

  @override
  Widget build(BuildContext context) {
    final blobs = Stack(
      fit: StackFit.expand,
      children: [
         ColoredBox(color: base),
        Positioned(
          top: -90.h,
          left: -70.w,
          child: _FluidBlob(
            size: 300.r,
            color: const Color(0xFF48CAE4).withValues(alpha: 0.7),
          ),
        ),
        Positioned(
          top: 160.h,
          right: -90.w,
          child: _FluidBlob(
            size: 280.r,
            color: AppColor.primary.withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          bottom: 40.h,
          left: -50.w,
          child: _FluidBlob(
            size: 260.r,
            color: AppColor.secondary.withValues(alpha: 0.35),
          ),
        ),
        Positioned(
          bottom: -80.h,
          right: -40.w,
          child: _FluidBlob(
            size: 220.r,
            color: const Color(0xFF00B4D8).withValues(alpha: 0.4),
          ),
        ),
      ],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: blobs,
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _FluidBlob extends StatelessWidget {
  const _FluidBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
