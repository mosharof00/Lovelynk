import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.path, {
    this.color,
    this.size,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    super.key,
  });

  final String path;
  final Color? color;

  /// Shorthand — sets both height and width equally
  final double? size;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    // ✅ Falls back to theme's iconTheme size — consistent with Icon()
    final iconSize = size ?? Theme.of(context).iconTheme.size ?? 24;

    return SvgPicture.asset(
      path,
      height: height ?? iconSize,
      width: width ?? iconSize,
      fit: fit,
      alignment: alignment,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
