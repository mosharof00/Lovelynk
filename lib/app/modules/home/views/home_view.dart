import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:bulkretail/app/global/widgets/app_text.dart';
import 'package:bulkretail/app/global/widgets/appbar_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppBarTitle("Home"), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset(AppConfig.appLogo, width: 200.w,)),

          20.height,
          AppText(
            "Welcome to Flutter Boilerplate with GetX CLI\n by Mosharof Khan",
            style: context.titleMedium.copyWith(fontSize: 25.sp,color: AppColor.primary),
            textAlign: TextAlign.center,

          ),
        ],
      ),
    );
  }
}
