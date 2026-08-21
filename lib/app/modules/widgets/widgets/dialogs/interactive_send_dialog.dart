import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';

/// Shared “send” dialog shell for Heartbeat / Kiss / Emoji.
///
/// Soft frosted panel, hero art with two white rings, floating love icons,
/// underlined “View details”, and a primary Send button.
class InteractiveSendDialog extends StatefulWidget {
  const InteractiveSendDialog({
    super.key,
    required this.title,
    required this.message,
    required this.sendLabel,
    required this.onSend,
    required this.onViewDetails,
    required this.hero,
    this.belowHero,
  });

  final String title;
  final String message;
  final String sendLabel;
  final VoidCallback onSend;
  final VoidCallback onViewDetails;

  /// Center image / emoji (rings + floating hearts wrap this).
  final Widget hero;

  /// Optional content under the message (e.g. emoji picker).
  final Widget? belowHero;

  static Future<void> show({
    required String title,
    required String message,
    required String sendLabel,
    required VoidCallback onSend,
    required VoidCallback onViewDetails,
    required Widget hero,
    Widget? belowHero,
  }) {
    return Get.dialog(
      InteractiveSendDialog(
        title: title,
        message: message,
        sendLabel: sendLabel,
        onSend: onSend,
        onViewDetails: onViewDetails,
        hero: hero,
        belowHero: belowHero,
      ),
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }

  @override
  State<InteractiveSendDialog> createState() => _InteractiveSendDialogState();
}

class _InteractiveSendDialogState extends State<InteractiveSendDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.88.sh),
        decoration: BoxDecoration(
          color: AppColor.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Stack(
            children: [
              // Soft pink / purple glow corners (like the mock).
              Positioned(
                top: -60.h,
                left: -40.w,
                child: _GlowBlob(
                  color: AppColor.primary.withValues(alpha: 0.18),
                  size: 160.r,
                ),
              ),
              Positioned(
                bottom: 80.h,
                right: -50.w,
                child: _GlowBlob(
                  color: const Color(0xFFB794F6).withValues(alpha: 0.16),
                  size: 180.r,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 22.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogHeader(title: widget.title),
                    8.verticalSpace,
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _HeroStage(
                              pulse: _pulse,
                              child: widget.hero,
                            ),
                            18.verticalSpace,
                            AppText(
                              widget.message,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                                height: 1.35,
                              ),
                            ),
                            if (widget.belowHero != null) ...[
                              16.verticalSpace,
                              widget.belowHero!,
                            ],
                            16.verticalSpace,
                            GestureDetector(
                              onTap: widget.onViewDetails,
                              behavior: HitTestBehavior.opaque,
                              child: AppText(
                                'View details',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    18.verticalSpace,
                    GlobalButton(
                      onTap: widget.onSend,
                      text: widget.sendLabel,
                      height: 52.h,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColor.textPrimary,
          ),
        ),
        Expanded(
          child: AppText(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }
}

class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.pulse, required this.child});

  final Animation<double> pulse;
  final Widget child;

  static const _loves = [
    _LoveSpec(dx: -0.72, dy: -0.55, size: 22, phase: 0.0),
    _LoveSpec(dx: 0.70, dy: -0.48, size: 18, phase: 0.4),
    _LoveSpec(dx: -0.78, dy: 0.15, size: 16, phase: 0.8),
    _LoveSpec(dx: 0.76, dy: 0.22, size: 20, phase: 1.2),
    _LoveSpec(dx: -0.35, dy: 0.72, size: 14, phase: 1.6),
    _LoveSpec(dx: 0.38, dy: 0.70, size: 17, phase: 2.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240.w,
      height: 240.w,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final t = pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _Ring(size: 220.w, opacity: 0.55 + t * 0.15),
              _Ring(size: 180.w, opacity: 0.75 + t * 0.1),
              for (final love in _loves)
                _FloatingLove(spec: love, t: t),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.55),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _LoveSpec {
  const _LoveSpec({
    required this.dx,
    required this.dy,
    required this.size,
    required this.phase,
  });

  final double dx;
  final double dy;
  final double size;
  final double phase;
}

class _FloatingLove extends StatelessWidget {
  const _FloatingLove({required this.spec, required this.t});

  final _LoveSpec spec;
  final double t;

  @override
  Widget build(BuildContext context) {
    final bob = math.sin((t * math.pi * 2) + spec.phase) * 6.h;
    return Align(
      alignment: Alignment(spec.dx, spec.dy),
      child: Transform.translate(
        offset: Offset(0, bob),
        child: Transform.rotate(
          angle: math.sin(spec.phase) * 0.35,
          child: Assets.images.lovePngIcon.image(
            width: spec.size.w,
            height: spec.size.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
