import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_affirmation_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_how_to_tips.dart';
import '../widgets/home_recent_activity.dart';
import '../widgets/home_stats_row.dart';
import '../widgets/partner_distance_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              16.verticalSpace,
              const PartnerDistanceCard(),
              12.verticalSpace,
              const HomeStatsRow(),
              12.verticalSpace,
              const HomeAffirmationCard(),
              12.verticalSpace,
              const HomeRecentActivity(),
              20.verticalSpace,
              const HomeHowToTips(),
              // Long-press header area helper: double-tap avatar via debug in controller.
              // Temporary UI switch for solo ↔ connected preview:
              16.verticalSpace,
              Center(
                child: TextButton(
                  onPressed: controller.toggleConnectedPreview,
                  child: Text(
                    'Preview: toggle solo / connected',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColor.hintText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
