import 'dart:math' as math;

import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/services/subscription_service.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

/// Thin Couples-Joy-style PRO banner with hearts rising bottom → top.
class ProfileSubscriptionBanner extends StatelessWidget {
  const ProfileSubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Get.find<SubscriptionService>();

    return Obx(() {
      if (subscription.state.value.isPremium) {
        return const SizedBox.shrink();
      }

      return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.SUBSCRIPTIONS),
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          height: 72.h,
          decoration: BoxDecoration(
            color: AppColor.primaryLight,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const _FlyingHeartsBackground(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    AppConfig.appName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.textPrimary,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                6.horizontalSpace,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.primary,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            4.verticalSpace,
                            Text(
                              'Unlock all widgets & premium features',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColor.textSecondary,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.horizontalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primary.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'BUY NOW',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            2.horizontalSpace,
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 16.sp,
                              color: AppColor.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
}

class _FlyingHeartsBackground extends StatefulWidget {
  const _FlyingHeartsBackground();

  @override
  State<_FlyingHeartsBackground> createState() =>
      _FlyingHeartsBackgroundState();
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

class _FlyingHeartsBackgroundState extends State<_FlyingHeartsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_FlyingHeart> _hearts;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _hearts = List.generate(10, (i) {
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
    return AnimatedBuilder(
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
    );
  }

  Widget _buildHeart(_FlyingHeart heart, double w, double h, int cycleMs) {
    final heartMs = heart.duration.inMilliseconds;
    final delayMs = heart.delay.inMilliseconds;
    final elapsed =
        ((_controller.value * cycleMs) - delayMs) % math.max(heartMs, 1);
    final t = (elapsed < 0 ? elapsed + heartMs : elapsed) / heartMs;

    // Ease out slightly so they linger near the top.
    final eased = Curves.easeInOut.transform(t);
    final y = h + heart.size - eased * (h + heart.size * 2);
    final x = (heart.x + heart.drift * math.sin(t * math.pi * 2)) * w;
    // Fade in/out at edges.
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
          color: AppColor.primary.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
