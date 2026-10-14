import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/text_style_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_input_text_form_field.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Icons.lock_outline_rounded,
                      color: AppColor.primary,
                      size: 34.sp,
                    ),
                  ),
                ),
                20.verticalSpace,
                AppText(
                  'Forgot password?',
                  style: context.headlineLarge.copyWith(
                    color: AppColor.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                8.verticalSpace,
                AppText(
                  "Enter your account email and we'll send you a code to reset your password.",
                  style: context.bodyMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                32.verticalSpace,
                AppInputTextFormField(
                  controller: controller.emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
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
                28.verticalSpace,
                Obx(
                  () => GlobalButton(
                    text: 'Send Code',
                    onTap: controller.sendCode,
                    isLoading: controller.isLoading.value,
                  ),
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
