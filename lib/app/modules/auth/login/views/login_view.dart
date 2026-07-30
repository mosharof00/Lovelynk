import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../core/extensions/text_style_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_input_text_form_field.dart';
import '../../../../global/widgets/app_scaffold.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              32.verticalSpace,
              Center(
                child: AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 36.sp,
                  color: AppColor.primary,
                ),
              ),
              20.verticalSpace,
              AppText(
                'Welcome back',
                style: context.headlineLarge.copyWith(
                  color: AppColor.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              8.verticalSpace,
              AppText(
                'Sign in to continue with lovelynk',
                style: context.bodyMedium.copyWith(
                  color: AppColor.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              36.verticalSpace,
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
                hintText: 'Enter your password',
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
              28.verticalSpace,
              GlobalButton(
                text: 'Sign In',
                onTap: controller.login,

              ),
              18.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    "Don't have an account? ",
                    style: context.bodyMedium.copyWith(
                      color: AppColor.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: controller.goToRegister,
                    child: AppText(
                      'Sign up',
                      style: context.titleSmall.copyWith(
                        color: AppColor.secondary,
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
    );
  }
}
