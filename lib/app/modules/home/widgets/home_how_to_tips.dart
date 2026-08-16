import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';

class HomeHowToTips extends StatelessWidget {
  const HomeHowToTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'How to add widget',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          4.verticalSpace,
          AppText(
            'Choose your device to see step-by-step instructions.',
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
          14.verticalSpace,
          _HowToRow(
            imagePath: Assets.images.lockScreenDemo.path,
            title: 'Lock Screen',
            body:
                'See how to add ${AppConfig.appName} widgets to your lock screen.',
            onTap: () => _AddWidgetInstructionsSheet.show(isLockScreen: true),
          ),
          12.verticalSpace,
          _HowToRow(
            imagePath: Assets.images.homeScreenDemo.path,
            title: 'Home Screen',
            body:
                'See how to add ${AppConfig.appName} widgets to your home screen.',
            onTap: () => _AddWidgetInstructionsSheet.show(isLockScreen: false),
          ),
        ],
      ),
    );
  }
}

class _HowToRow extends StatelessWidget {
  const _HowToRow({
    required this.imagePath,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              imagePath,
              width: 72.w,
              height: 72.w,
              fit: BoxFit.cover,
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                4.verticalSpace,
                AppText(
                  body,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColor.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddWidgetInstructionsSheet extends StatelessWidget {
  const _AddWidgetInstructionsSheet({required this.isLockScreen});

  final bool isLockScreen;

  static Future<void> show({required bool isLockScreen}) {
    return Get.bottomSheet(
      _AddWidgetInstructionsSheet(isLockScreen: isLockScreen),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  String get _imagePath => isLockScreen
      ? Assets.images.lockScreenDemo.path
      : Assets.images.homeScreenDemo.path;

  String get _title =>
      isLockScreen ? 'Add to Lock Screen' : 'Add to Home Screen';

  String get _subtitle =>
      'Follow these steps on your iPhone to add a ${AppConfig.appName} widget.';

  List<_Step> get _steps {
    final name = AppConfig.appName;
    if (isLockScreen) {
      return [
        const _Step(
          'Touch and hold the Lock Screen until the Customise button appears.',
        ),
        const _Step('Tap Customise, then tap Lock Screen.'),
        const _Step('Tap Add Widgets below the clock.'),
        _Step('Search for $name, then tap a widget to add it.'),
        const _Step('Tap Done in the top-right corner.'),
      ];
    }
    return [
      const _Step(
        'Touch and hold an empty area on the Home Screen until the apps jiggle.',
      ),
      const _Step('Tap the + button in the top-left corner.'),
      _Step('Search for $name and select a widget size.'),
      const _Step('Tap Add Widget, then tap Done.'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColor.inputBorder,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              16.verticalSpace,
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    _imagePath,
                    width: 180.w,
                    height: 180.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              16.verticalSpace,
              AppText(
                _title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            6.verticalSpace,
            AppText(
              _subtitle,
              maxLines: 3,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary,
                height: 1.4,
              ),
            ),
            18.verticalSpace,
            for (int i = 0; i < steps.length; i++) ...[
              _StepRow(number: i + 1, text: steps[i].text),
              if (i != steps.length - 1) 12.verticalSpace,
            ],
            8.verticalSpace,
          ],
        ),
      ),
      ),
    );
  }
}

class _Step {
  const _Step(this.text);
  final String text;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: const BoxDecoration(
            color: AppColor.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AppText(
            '$number',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: AppText(
            text,
            maxLines: 4,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColor.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
