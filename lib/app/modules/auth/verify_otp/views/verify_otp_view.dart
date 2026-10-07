import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/text_style_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_input_text_form_field.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';
import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({super.key});

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
                      Icons.mark_email_read_outlined,
                      color: AppColor.primary,
                      size: 34.sp,
                    ),
                  ),
                ),
                20.verticalSpace,
                AppText(
                  'Verify your email',
                  style: context.headlineLarge.copyWith(
                    color: AppColor.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                8.verticalSpace,
                AppText(
                  'Enter the ${controller.codeLength}-digit code we sent to\n${controller.email}',
                  style: context.bodyMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                32.verticalSpace,
                AutofillGroup(
                  child: AppInputTextFormField(
                    controller: controller.codeController,
                    hintText: '•' * controller.codeLength,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: controller.codeLength,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: context.headlineLarge.copyWith(
                      color: AppColor.textPrimary,
                      letterSpacing: 8,
                    ),
                    autovalidateMode: AutovalidateMode.disabled,
                    onChanged: controller.onCodeChanged,
                    validator: (value) {
                      if ((value ?? '').length != controller.codeLength) {
                        return 'Enter the ${controller.codeLength}-digit code';
                      }
                      return null;
                    },
                  ),
                ),
                24.verticalSpace,
                Obx(
                  () => GlobalButton(
                    text: 'Verify',
                    onTap: controller.verify,
                    isLoading: controller.isVerifying.value,
                  ),
                ),
                18.verticalSpace,
                Obx(() {
                  final seconds = controller.resendSeconds.value;
                  final canResend =
                      seconds == 0 && !controller.isResending.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        "Didn't get the code? ",
                        style: context.bodyMedium.copyWith(
                          color: AppColor.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: canResend ? controller.resend : null,
                        child: AppText(
                          seconds > 0 ? 'Resend in ${seconds}s' : 'Resend',
                          style: context.titleSmall.copyWith(
                            color: canResend
                                ? AppColor.primary
                                : AppColor.hintText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
