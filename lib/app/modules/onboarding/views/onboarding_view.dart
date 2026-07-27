import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/config/app_config.dart';
import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            children: [
              30.verticalSpace,
              Image.asset(AppConfig.appLogo, height: 90.h, width: 90.w),
              AppText(
                AppConfig.appName,
                style: context.titleLarge.copyWith(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              48.verticalSpace,
              AppText(
                'Together, even when apart.',
                style: context.displayMedium.copyWith(
                  color: AppColor.textPrimary,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              12.verticalSpace,
                  AppSvgIcon(
                    Assets.icons.loveIcon,
                    size: 16.sp,
                    color: AppColor.primary,
                  ),
              AppText(
                'The #1 app for long distance relationship widgets',
                style: context.bodyMedium.copyWith(
                  color: AppColor.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              10.verticalSpace,
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     AppSvgIcon(
              //       Assets.icons.loveIcon,
              //       size: 42.sp,
              //       color: AppColor.primary,
              //     ),
              //     18.horizontalSpace,
              //     AppSvgIcon(
              //       Assets.icons.loveIcon,
              //       size: 42.sp,
              //       color: AppColor.secondary,
              //     ),
              //   ],
              // ),

              Image.asset(Assets.images.onboardImage2.path, width: Get.width,),
              const Spacer(),
              GlobalButton(text: 'Continue', onTap: controller.continueToLogin),
              28.verticalSpace,

            ],
          ),
        ),
      ),
    );
  }
}
