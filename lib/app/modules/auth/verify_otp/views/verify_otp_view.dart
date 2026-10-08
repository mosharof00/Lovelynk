import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/extensions/text_style_extension.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';
import '../../../../global/widgets/global_button.dart';
import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: context.headlineLarge.copyWith(color: AppColor.textPrimary),
      decoration: BoxDecoration(
        color: AppColor.inputFill,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.inputBorder),
      ),
    );

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
                      controller.isRecovery
                          ? Icons.lock_reset_rounded
                          : Icons.mark_email_read_outlined,
                      color: AppColor.primary,
                      size: 34.sp,
                    ),
                  ),
                ),
                20.verticalSpace,
                AppText(
                  controller.title,
                  style: context.headlineLarge.copyWith(
                    color: AppColor.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                8.verticalSpace,
                AppText(
                  controller.subtitle,
                  style: context.bodyMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),
                32.verticalSpace,
                Pinput(
                  length: controller.codeLength,
                  controller: controller.codeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  separatorBuilder: (_) => SizedBox(width: 8.w),
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: AppColor.primary, width: 1.4),
                  ),
                  submittedPinTheme: defaultPinTheme.copyDecorationWith(
                    color: AppColor.primaryLight,
                    border: Border.all(color: AppColor.primary),
                  ),
                  errorPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: AppColor.error),
                  ),
                  pinputAutovalidateMode: PinputAutovalidateMode.disabled,
                  validator: (value) {
                    if ((value ?? '').length != controller.codeLength) {
                      return 'Enter the ${controller.codeLength}-digit code';
                    }
                    return null;
                  },
                ),
                28.verticalSpace,
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
