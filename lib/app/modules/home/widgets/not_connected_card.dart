import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_text.dart';
import 'package:bulkretail/app/global/widgets/global_button.dart';
import 'package:bulkretail/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotConnectedCard extends StatefulWidget {
  const NotConnectedCard({super.key});

  @override
  State<NotConnectedCard> createState() => _NotConnectedCardState();
}

class _NotConnectedCardState extends State<NotConnectedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _beat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Soft double-pulse (heartbeat): up-down, pause, up-down, pause.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.035)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.035, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 48,
      ),
    ]).animate(_beat);
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final connected = controller.isConnected.value;
      if (connected) {
        if (_beat.isAnimating) _beat.stop();
        return const SizedBox.shrink();
      }

      if (!_beat.isAnimating) _beat.repeat();

      return ScaleTransition(
        scale: _scale,
        child: Container(
          margin: EdgeInsets.only(top: 12.h),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColor.inputBorder.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(AppConfig.appLogo, height: 56.w, width: 56.w),
              12.width,
              Expanded(
                child: AppText(
                  'Connect with your partner',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              12.width,
              GlobalButton(
                onTap: controller.goConnectPartner,
                text: 'Connect',
                fontSize: 12.sp,
                height: 32.h,
                width: 84.w,
              ),
            ],
          ),
        ),
      );
    });
  }
}
