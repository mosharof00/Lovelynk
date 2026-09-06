import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            children: [
              Stack(
                children: [
                  Image.asset(AppConfig.appLogo, width: 180.w),
                  Positioned(
                    top: 120.h,
                    left: 50.w,
                    right: 50.w,
                    child: AppText(
                      AppConfig.appName,
                      style: context.titleLarge.copyWith(
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              30.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    '    Together,\neven when apart',
                    style: context.headlineLarge.copyWith(
                      color: AppColor.textPrimary,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                  5.width,
                  AppSvgIcon(
                    Assets.icons.loveIcon,
                    size: 16.sp,
                    color: AppColor.primary,
                  ),
                ],
              ),
              16.verticalSpace,
              AppSvgIcon(
                Assets.icons.loveIcon,
                size: 16.sp,
                color: AppColor.primary,
              ),
              16.verticalSpace,
              AppText(
                'The #1 app for long distance relationship widgets',
                style: context.bodyMedium.copyWith(
                  color: AppColor.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              16.verticalSpace,
              AppSvgIcon(
                Assets.icons.loveIcon,
                size: 16.sp,
                color: AppColor.primary,
              ),
              Image.asset(Assets.images.onboardImage2.path, width: Get.width),
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
