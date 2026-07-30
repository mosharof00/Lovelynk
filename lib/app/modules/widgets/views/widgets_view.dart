import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../global/widgets/app_scaffold.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/widgets_controller.dart';
import '../widgets/widget_category_section.dart';

class WidgetsView extends GetView<WidgetsController> {
  const WidgetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Obx(() {
        final unlocked =
            Get.find<SubscriptionService>().state.value.isWidgetsUnlocked;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Widgets',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    4.verticalSpace,
                    AppText(
                      'Discover and add beautiful widgets',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    12.verticalSpace,
                    if (!unlocked)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryLight,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: AppText(
                          'Trial ended — widgets are locked. Unlock to continue.',
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: controller.debugExpireTrial,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: AppText(
                            'Preview locked state (dev)',
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
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final category in WidgetCategory.values) ...[
                    WidgetCategorySection(
                      category: category,
                      widgets: controller.widgetsFor(category),
                      isUnlocked: unlocked,
                      onAdd: controller.onAddTap,
                      onUnlock: controller.onUnlockTap,
                    ),
                    24.verticalSpace,
                  ],
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}
