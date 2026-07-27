import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/extensions/text_style_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_input_text_form_field.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                24.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20.sp,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                8.verticalSpace,
                Center(
                  child: AppSvgIcon(
                    Assets.icons.loveIcon,
                    size: 36.sp,
                    color: AppColor.primary,
                  ),
                ),
                16.verticalSpace,
                AppText(
                  'Create your account',
                  style: context.headlineLarge.copyWith(
                    color: AppColor.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                8.verticalSpace,
                AppText(
                  'Join lovelynk in one simple step',
                  style: context.bodyMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                28.verticalSpace,
                AppInputTextFormField(
                  controller: controller.nameController,
                  hintText: 'Enter your first name',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                14.verticalSpace,
                AppInputTextFormField(
                  controller: controller.emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!GetUtils.isEmail(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                14.verticalSpace,
                PasswordInputField(
                  controller: controller.passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                14.verticalSpace,
                PasswordInputField(
                  controller: controller.confirmPasswordController,
                  hintText: 'Confirm your password',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                28.verticalSpace,
                GlobalButton(
                  text: 'Continue',
                  onTap: controller.register,
                ),
                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      'Already have an account? ',
                      style: context.bodyMedium.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: AppText(
                        'Sign in',
                        style: context.titleSmall.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
