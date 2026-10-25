import 'dart:math' as math;

import 'package:bulkretail/app/core/theme/app_gradient.dart';
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
/// partner tip card with setup-guide CTA, and Send.
class InteractiveSendDialog extends StatefulWidget {
  const InteractiveSendDialog({
    super.key,
    required this.title,
    required this.message,
    required this.sendLabel,
    required this.onSend,
    this.onSendWithCount,
    this.enableMultiCount = false,
    required this.hero,
    required this.partnerName,
    required this.widgetLabel,
    required this.tipEmoji,
    this.belowHero,
  });

  final String title;
  final String message;
  final String sendLabel;
  final VoidCallback onSend;
  final ValueChanged<int>? onSendWithCount;
  final bool enableMultiCount;

  /// Center image / emoji (rings + floating hearts wrap this).
  final Widget hero;

  /// Partner first name used in the tip card copy.
  final String partnerName;

  /// e.g. "Heartbeat", "Kiss", "Emoji".
  final String widgetLabel;

  /// Trailing emoji on the tip (💗 / 💋 / etc.).
  final String tipEmoji;

  /// Optional content under the message (e.g. emoji picker).
  final Widget? belowHero;

  static Future<void> show({
    required String title,
    required String message,
    required String sendLabel,
    required VoidCallback onSend,
    ValueChanged<int>? onSendWithCount,
    bool enableMultiCount = false,
    required Widget hero,
    required String partnerName,
    required String widgetLabel,
    required String tipEmoji,
    Widget? belowHero,
  }) {
    return Get.dialog(
      InteractiveSendDialog(
        title: title,
        message: message,
        sendLabel: sendLabel,
        onSend: onSend,
        onSendWithCount: onSendWithCount,
        enableMultiCount: enableMultiCount,
        hero: hero,
        partnerName: partnerName,
        widgetLabel: widgetLabel,
        tipEmoji: tipEmoji,
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
  bool _showTip = true;
  int _count = 1;
  late final TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: '1');
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countController.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _updateCount(int newCount) {
    final clamped = newCount.clamp(1, 100);
    setState(() {
      _count = clamped;
      _countController.text = '$clamped';
    });
  }

  String get _buttonText {
    if (!widget.enableMultiCount || _count == 1) {
      return widget.sendLabel;
    }
    final plural = widget.widgetLabel == 'Kiss'
        ? 'Kisses 💋'
        : (widget.widgetLabel == 'Heartbeat' ? 'Heartbeats 💗' : widget.widgetLabel);
    return 'Send $_count $plural';
  }

  void _handleSend() {
    if (widget.enableMultiCount && widget.onSendWithCount != null) {
      widget.onSendWithCount!(_count);
    } else {
      widget.onSend();
    }
  }

  String get _partnerFirst {
    final name = widget.partnerName.trim();
    if (name.isEmpty) return 'Your partner';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.88.sh),
        decoration: BoxDecoration(
          // color: AppColor.white.withValues(alpha: 0.96),
          // color: AppColor.background,
          gradient: AppGradient.brandSoft,
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
              // Positioned(
              //   top: 60.h,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     height: 200.h,
              //     width: 200.h,
              //     decoration: BoxDecoration(
              //       color: Colors.white.withAlpha(25),
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: Colors.white.withAlpha(100),
              //         width: 2,
              //       ),
              //     ),
              //   ),
              // ),
              //
              // Positioned(
              //   top: 80.h,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     height: 160.h,
              //     width: 160.h,
              //     decoration: BoxDecoration(
              //       color: Colors.white.withAlpha(25),
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: Colors.white.withAlpha(100),
              //         width: 2,
              //       ),
              //     ),
              //   ),
              // ),
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
                            _HeroStage(pulse: _pulse, child: widget.hero),
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
                            if (widget.enableMultiCount) ...[
                              14.verticalSpace,
                              _CountSelector(
                                count: _count,
                                controller: _countController,
                                onChanged: _updateCount,
                              ),
                            ],
                            if (widget.belowHero != null) ...[
                              16.verticalSpace,
                              widget.belowHero!,
                            ],
                            if (_showTip) ...[
                              16.verticalSpace,
                              _PartnerWidgetTipCard(
                                message:
                                    '$_partnerFirst needs the ${widget.widgetLabel} widget on their lock screen to feel this ${widget.tipEmoji}',
                                onClose: () => setState(() => _showTip = false),
                                onSendGuide: () {
                                  Get.snackbar(
                                    'Setup guide',
                                    'We’ll notify $_partnerFirst to add the ${widget.widgetLabel} widget.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColor.primaryLight,
                                    colorText: AppColor.textPrimary,
                                    margin: const EdgeInsets.all(16),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    18.verticalSpace,
                    GlobalButton(onTap: _handleSend, text: _buttonText),
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
          icon: Container(
            height: 30.w,
            width: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12.withAlpha(25),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: Colors.black,
            ),
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

class _PartnerWidgetTipCard extends StatelessWidget {
  const _PartnerWidgetTipCard({
    required this.message,
    required this.onClose,
    required this.onSendGuide,
  });

  final String message;
  final VoidCallback onClose;
  final VoidCallback onSendGuide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withAlpha(150), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h, right: 4.w),
                  child: AppText(
                    message,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          10.verticalSpace,
          GestureDetector(
            onTap: onSendGuide,
            behavior: HitTestBehavior.opaque,
            child: AppText(
              'Send them the setup guide →',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
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
              _Ring(size: 220.w),
              _Ring(size: 180.w),
              for (final love in _loves) _FloatingLove(spec: love, t: t),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withAlpha(100), width: 2),
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

class _CountSelector extends StatelessWidget {
  const _CountSelector({
    required this.count,
    required this.controller,
    required this.onChanged,
  });

  final int count;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  static const _presets = [1, 5, 10, 25, 50, 99];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stepper: [-]  [ Input ]  [+]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              enabled: count > 1,
              onTap: () => onChanged(count - 1),
            ),
            12.horizontalSpace,
            Container(
              width: 84.w,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed >= 1 && parsed <= 100) {
                    onChanged(parsed);
                  }
                },
              ),
            ),
            12.horizontalSpace,
            _StepButton(
              icon: Icons.add_rounded,
              enabled: count < 100,
              onTap: () => onChanged(count + 1),
            ),
          ],
        ),
        10.verticalSpace,
        // Quick Presets
        Wrap(
          spacing: 6.w,
          runSpacing: 6.h,
          alignment: WrapAlignment.center,
          children: [
            for (final preset in _presets)
              InkWell(
                onTap: () => onChanged(preset),
                borderRadius: BorderRadius.circular(16.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: count == preset
                        ? AppColor.primary
                        : Colors.white.withAlpha(220),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: count == preset
                          ? AppColor.primary
                          : AppColor.inputBorder.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    '+$preset',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight:
                          count == preset ? FontWeight.w700 : FontWeight.w600,
                      color:
                          count == preset ? Colors.white : AppColor.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : Colors.white.withAlpha(120),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  AppColor.inputBorder.withValues(alpha: enabled ? 0.8 : 0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: enabled ? AppColor.textPrimary : AppColor.hintText,
          ),
        ),
      ),
    );
  }
}

