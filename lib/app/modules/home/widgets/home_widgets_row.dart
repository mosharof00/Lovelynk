import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/widget_catalog/widget_catalog.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/widgets/renderers/essentials_widgets.dart';
import '../../widgets/widgets/renderers/interactive_widgets.dart';
import '../../widgets/widgets/renderers/love_widget_card.dart';
import '../../widgets/widgets/renderers/relationship_widgets.dart';
import '../controllers/home_controller.dart';

/// Home preview strip: Days Together, Kiss, Anniversary — content only (no Add/Send).
class HomeWidgetsRow extends GetView<HomeController> {
  const HomeWidgetsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = Get.find<SubscriptionService>();
    final daysDef = WidgetCatalog.byType(AppWidgetType.daysTogether)!;
    final kissDef = WidgetCatalog.byType(AppWidgetType.kiss)!;
    final anniversaryDef = WidgetCatalog.byType(AppWidgetType.anniversary)!;

    return Obx(() {
      final unlocked = subscription.state.value.isWidgetsUnlocked;

      return SizedBox(
        height: 110.h,
        child: Row(
          children: [
            Expanded(
              child: LoveWidgetCard(
                title: daysDef.title,
                isUnlocked: unlocked,
                compact: true,
                showFooter: false,
                onAction: () => _openWidgetsOrPaywall(unlocked),
                child: const DaysTogetherWidget(compact: true),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: LoveWidgetCard(
                title: kissDef.title,
                isUnlocked: unlocked,
                compact: true,
                showFooter: false,
                onAction: () => _openWidgetsOrPaywall(unlocked),
                child: const KissWidget(compact: true),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: LoveWidgetCard(
                title: anniversaryDef.title,
                isUnlocked: unlocked,
                compact: true,
                showFooter: false,
                onAction: () => _openWidgetsOrPaywall(unlocked),
                child: const AnniversaryWidget(compact: true),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _openWidgetsOrPaywall(bool unlocked) {
    if (!unlocked) {
      Get.toNamed(Routes.SUBSCRIPTIONS);
    }
  }
}
