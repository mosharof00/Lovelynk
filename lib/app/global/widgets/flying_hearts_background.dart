import 'dart:math' as math;

import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';

/// Soft hearts rising bottom → top. Tint with [color] (defaults to primary).
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
    required this.duration,
    required this.delay,
    required this.opacity,
    required this.drift,
  });

  /// 0–1 horizontal position.
  final double x;
  final double size;
  final Duration duration;
  final Duration delay;
  final double opacity;
  final double drift;
}

class _FlyingHeartsBackgroundState extends State<FlyingHeartsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_FlyingHeart> _hearts;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _hearts = List.generate(widget.count, (i) {
      return _FlyingHeart(
        x: 0.06 + rng.nextDouble() * 0.88,
        size: 10 + rng.nextDouble() * 22,
        duration: Duration(milliseconds: 4200 + rng.nextInt(3800)),
        delay: Duration(milliseconds: rng.nextInt(3200)),
        opacity: 0.12 + rng.nextDouble() * 0.22,
        drift: (rng.nextDouble() - 0.5) * 0.12,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
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
              final cycleMs = _controller.duration!.inMilliseconds;

              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  for (final heart in _hearts)
                    _buildHeart(heart, w, h, cycleMs),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeart(_FlyingHeart heart, double w, double h, int cycleMs) {
    final heartMs = heart.duration.inMilliseconds;
    final delayMs = heart.delay.inMilliseconds;
    final elapsed =
        ((_controller.value * cycleMs) - delayMs) % math.max(heartMs, 1);
    final t = (elapsed < 0 ? elapsed + heartMs : elapsed) / heartMs;

    final eased = Curves.easeInOut.transform(t);
    final y = h + heart.size - eased * (h + heart.size * 2);
    final x = (heart.x + heart.drift * math.sin(t * math.pi * 2)) * w;
    final fade = (t < 0.12)
        ? t / 0.12
        : (t > 0.85)
            ? (1 - t) / 0.15
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
