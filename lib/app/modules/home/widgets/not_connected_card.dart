import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_text.dart';
import 'package:bulkretail/app/global/widgets/global_button.dart';
import 'package:bulkretail/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotConnectedCard extends GetView<HomeController> {
  const NotConnectedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isConnected.value) {
        return Container(
          margin: EdgeInsets.only(top: 12.h),
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColor.inputBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Image.asset(AppConfig.appLogo, height: 56.w, width: 56.w),
              12.width,
              Expanded(
                child: AppText(
                  'Connect with your partner',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              12.width,
              GlobalButton(
                onTap: controller.goConnectPartner,
                text: 'Connect',
                fontSize: 12.sp,
                height: 32.h,
                width: 84.w,
              ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
