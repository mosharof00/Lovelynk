import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/text_style_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_input_text_form_field.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.cancel();
      },
      child: Scaffold(
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
                      onPressed: controller.cancel,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20.sp,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                  16.verticalSpace,
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.key_rounded,
                        color: AppColor.primary,
                        size: 34.sp,
                      ),
                    ),
                  ),
                  20.verticalSpace,
                  AppText(
                    'Create new password',
                    style: context.headlineLarge.copyWith(
                      color: AppColor.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  8.verticalSpace,
                  AppText(
                    'Your new password must be different from the previous one.',
                    style: context.bodyMedium.copyWith(
                      color: AppColor.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                  32.verticalSpace,
                  PasswordInputField(
                    controller: controller.passwordController,
                    hintText: 'New password',
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
                    hintText: 'Confirm new password',
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
                  Obx(
                    () => GlobalButton(
                      text: 'Save Password',
                      onTap: controller.savePassword,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
