import 'package:bulkretail/app/global/animations/fade_in_animation.dart';
import 'package:bulkretail/app/global/widgets/notification_bell_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: FadeInAnimation(
              delay: 1,
              fromLeft: true,
              shouldAnimate: controller.isFadeInAnimate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Good morning,',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  AppText(
                    controller.userName.value,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FadeInAnimation(
            delay: 1,
            fromRight: true,
            shouldAnimate: controller.isFadeInAnimate,
            child: const NotificationBellButton(),
          ),
        ],
      ),
    );
  }
}
