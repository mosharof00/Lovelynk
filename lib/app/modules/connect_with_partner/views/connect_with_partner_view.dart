import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/app_scaffold.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/connect_with_partner_controller.dart';

class ConnectWithPartnerView extends GetView<ConnectWithPartnerController> {
  const ConnectWithPartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            12.verticalSpace,
            Row(
              children: [
                IconButton(
                  onPressed: controller.back,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
                    color: AppColor.textPrimary,
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => _StepDots(
                      current: controller.currentStep.value,
                      total: ConnectWithPartnerController.totalSteps,
                    ),
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
            20.verticalSpace,
            Expanded(
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case 0:
                    return const _PartnerNameStep();
                  case 1:
                    return const _AnniversaryStep();
                  default:
                    return const _ConnectCodeStep();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: isActive ? 10.h : 8.h,
          width: isActive ? 10.w : 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColor.primary : AppColor.primaryLight,
          ),
        );
      }),
    );
  }
}

class _PartnerNameStep extends GetView<ConnectWithPartnerController> {
  const _PartnerNameStep();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.nameFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            "Partner's name?",
            style: context.headlineLarge.copyWith(color: AppColor.textPrimary),
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,
          AppText(
            'Personalises everything.',
            style: context.bodyMedium.copyWith(color: AppColor.textSecondary),
            textAlign: TextAlign.center,
          ),
          36.verticalSpace,
          AppInputTextFormField(
            controller: controller.partnerNameController,
            hintText: "Enter your partner's name",
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: AppSvgIcon(
                Assets.icons.loveIcon,
                size: 18.sp,
                color: AppColor.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Partner's name is required";
              }
              return null;
            },
          ),
          const Spacer(),
          GlobalButton(
            text: 'Continue',
            onTap: controller.nextFromName,
          ),
          24.verticalSpace,
        ],
      ),
    );
  }
}

class _AnniversaryStep extends GetView<ConnectWithPartnerController> {
  const _AnniversaryStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          'Anniversary date',
          style: context.headlineLarge.copyWith(color: AppColor.textPrimary),
          textAlign: TextAlign.center,
        ),
        8.verticalSpace,
        AppText(
          'When did your story begin?',
          style: context.bodyMedium.copyWith(color: AppColor.textSecondary),
          textAlign: TextAlign.center,
        ),
        36.verticalSpace,
        Obx(
          () => AppInputTextFormField(
            key: ValueKey(controller.anniversaryLabel),
            hintText: 'Select your anniversary date',
            readOnly: true,
            initialValue: controller.anniversaryLabel.isEmpty
                ? null
                : controller.anniversaryLabel,
            onTap: () => controller.pickAnniversary(context),
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: AppColor.hintText,
              size: 20.sp,
            ),
          ),
        ),
        16.verticalSpace,
        Center(
          child: GestureDetector(
            onTap: controller.skipAnniversary,
            child: AppText(
              'Skip for now',
              style: context.titleSmall.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
            ),
          ),
        ),
        const Spacer(),
        GlobalButton(
          text: 'Continue',
          onTap: controller.continueFromAnniversary,
        ),
        24.verticalSpace,
      ],
    );
  }
}

class _ConnectCodeStep extends GetView<ConnectWithPartnerController> {
  const _ConnectCodeStep();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.codeFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              'Connect with your partner',
              style: context.headlineLarge.copyWith(
                color: AppColor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            AppText(
              'Share your code or enter theirs',
              style: context.bodyMedium.copyWith(
                color: AppColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            32.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 28.sp,
                  color: AppColor.primary,
                ),
                12.horizontalSpace,
                AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 28.sp,
                  color: AppColor.secondary,
                ),
              ],
            ),
            24.verticalSpace,
            AppText(
              controller.inviteCode,
              style: context.headlineLarge.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            AppText(
              'Expires in 59 minutes',
              style: context.bodySmall.copyWith(color: AppColor.hintText),
              textAlign: TextAlign.center,
            ),
            20.verticalSpace,
            GlobalButton(
              text: 'Send code',
              isOutlined: true,
              onTap: controller.sendCode,
            ),
            28.verticalSpace,
            AppInputTextFormField(
              controller: controller.partnerCodeController,
              hintText: "Enter your partner's code",
              keyboardType: TextInputType.number,
              prefixIcon: Icon(
                Icons.vpn_key_outlined,
                color: AppColor.hintText,
                size: 20.sp,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Partner's code is required";
                }
                if (value.trim().length != 8) {
                  return 'Code must be 8 digits';
                }
                return null;
              },
            ),
            28.verticalSpace,
            GlobalButton(
              text: 'Connect',
              onTap: controller.connect,
            ),
            24.verticalSpace,
          ],
        ),
      ),
    );
  }
}
