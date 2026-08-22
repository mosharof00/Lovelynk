import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../gen/assets.gen.dart';
import '../../core/theme/app_color.dart';
import '../../data/models/widget_models/widget_guide_step.dart';
import 'app_text.dart';
import 'global_button.dart';

/// Multi-step Home / Lock widget setup guide (iPhone 17 / latest iOS).
class WidgetSetupGuidePage extends StatelessWidget {
  const WidgetSetupGuidePage({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.onContinue,
  });

  final List<WidgetGuideStep> steps;
  final RxInt currentIndex;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
          child: Obx(() {
            final index = currentIndex.value.clamp(0, steps.length - 1);
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return Column(
              children: [
                _GuideHeader(),
                8.verticalSpace,
                Expanded(
                  child: Column(
                    children: [
                      AppText(
                        step.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      if (step.subtitle != null) ...[
                        10.verticalSpace,
                        AppText(
                          step.subtitle!,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColor.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      16.verticalSpace,
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            step.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (step.helpLabel != null) ...[
                        8.verticalSpace,
                        GestureDetector(
                          onTap: () => _showHelp(
                            context,
                            step.helpLabel!,
                            step.helpMessage ?? '',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                size: 16.sp,
                                color: AppColor.primary,
                              ),
                              6.horizontalSpace,
                              AppText(
                                step.helpLabel!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                16.verticalSpace,
                GlobalButton(
                  onTap: onContinue,
                  text: isLast ? 'Done' : 'Continue',
                  height: 52.h,
                  suffixWidget: isLast
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                ),
                14.verticalSpace,
                _Dots(count: steps.length, active: index),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showHelp(BuildContext context, String title, String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: AppText(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        content: AppText(
          message,
          maxLines: 8,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColor.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: Row(
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
            child: Center(
              child: Image.asset(
                Assets.logos.appLogo.path,
                height: 58.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: i == active ? 8.w : 7.w,
            height: i == active ? 8.w : 7.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == active
                  ? AppColor.primary
                  : AppColor.primaryDisable.withValues(alpha: 0.5),
            ),
          ),
          if (i != count - 1) 8.horizontalSpace,
        ],
      ],
    );
  }
}
