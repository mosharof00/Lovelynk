import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_color.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Center(
          child: Image.asset(AppConfig.splashLogo, fit: BoxFit.cover)
              .animate() // Chain the animation
              .fadeIn(duration: Duration(seconds: 1))
              .slide(
                begin: Offset(-0.2, 0),
                end: Offset(0, 0),
                duration: Duration(seconds: 2),
              ),
        ),
      ),
    );
  }
}
