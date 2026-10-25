import 'dart:math' as math;

import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Soft hearts rising bottom → top continuously without jarring resets.
/// Tint with [color] (defaults to primary).
class FlyingHeartsBackground extends StatefulWidget {
  const FlyingHeartsBackground({
    super.key,
    this.color = AppColor.primary,
    this.count = 10,
  });

  final Color color;
  final int count;

  @override
  State<FlyingHeartsBackground> createState() => _FlyingHeartsBackgroundState();
}

class _FlyingHeart {
  _FlyingHeart({
    required this.x,
    required this.size,
    required this.durationSeconds,
    required this.initialProgress,
    required this.opacity,
    required this.drift,
  });

  /// 0–1 horizontal base position.
  final double x;
  final double size;
  final double durationSeconds;
  final double initialProgress;
  final double opacity;
  final double drift;
}

class _FlyingHeartsBackgroundState extends State<FlyingHeartsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Stopwatch _stopwatch = Stopwatch();
  late final List<_FlyingHeart> _hearts;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _hearts = List.generate(widget.count, (i) {
      return _FlyingHeart(
        x: 0.06 + rng.nextDouble() * 0.88,
        size: 10.0 + rng.nextDouble() * 20.0,
        durationSeconds: 7.0 + rng.nextDouble() * 5.0, // 7 to 12 seconds per rise
        initialProgress: rng.nextDouble(), // Spread evenly across card on load
        opacity: 0.12 + rng.nextDouble() * 0.20,
        drift: (rng.nextDouble() - 0.5) * 0.12,
      );
    });

    _stopwatch.start();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..forward();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final elapsedSeconds = _stopwatch.elapsedMicroseconds / 1000000.0;

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  for (final heart in _hearts)
                    _buildHeart(heart, w, h, elapsedSeconds),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeart(_FlyingHeart heart, double w, double h, double elapsedSeconds) {
    // Each heart has its own independent continuous progress that loops [0.0, 1.0)
    final t = (heart.initialProgress + (elapsedSeconds / heart.durationSeconds)) % 1.0;

    // Linear upward motion for smooth, constant, natural buoyancy
    final y = h + heart.size - t * (h + heart.size * 2);
    final x = (heart.x + heart.drift * math.sin(t * math.pi * 2)) * w;

    // Smooth fade in near the bottom and fade out near the top
    final fade = (t < 0.15)
        ? (t / 0.15)
        : (t > 0.85)
            ? ((1.0 - t) / 0.15)
            : 1.0;

    return Positioned(
      left: x - heart.size / 2,
      top: y,
      child: Opacity(
        opacity: (heart.opacity * fade).clamp(0.0, 1.0),
        child: AppSvgIcon(
          Assets.icons.loveIcon,
          size: heart.size,
          color: widget.color.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
