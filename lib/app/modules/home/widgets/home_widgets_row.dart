import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/services/widget_data_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/widget_catalog/widget_catalog.dart';
import '../../../routes/app_pages.dart';
import '../../main_page/controllers/main_page_controller.dart';
import '../../widgets/widgets/dialogs/kiss_send_dialog.dart';
import '../../widgets/widgets/renderers/essentials_widgets.dart';
import '../../widgets/widgets/renderers/interactive_widgets.dart';
import '../../widgets/widgets/renderers/love_widget_card.dart';
import '../../widgets/widgets/renderers/relationship_widgets.dart';
import '../controllers/home_controller.dart';

/// Home preview strip: Days Together, Kiss, Anniversary — same data as Widgets,
/// with [LoveWidgetCard.compact] sizing for narrow columns.
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
        height: 130.h,
        child: Row(
          children: [
            Expanded(
              child: LoveWidgetCard(
                title: daysDef.title,
                isUnlocked: unlocked,
                compact: true,
                onAction: () => _onAction(unlocked),
                child: const DaysTogetherWidget(compact: true),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: LoveWidgetCard(
                title: kissDef.title,
                isUnlocked: unlocked,
                compact: true,
                onAction: () => _onAction(unlocked),
                onSend: unlocked ? _onSendKiss : () => _onAction(false),
                sendLabel: kissDef.sendLabel,
                child: const KissWidget(compact: true),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: LoveWidgetCard(
                title: anniversaryDef.title,
                isUnlocked: unlocked,
                compact: true,
                onAction: () => _onAction(unlocked),
                child: const AnniversaryWidget(compact: true),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _onAction(bool unlocked) {
    if (!unlocked) {
      Get.toNamed(Routes.SUBSCRIPTIONS);
      return;
    }
    Get.find<MainPageController>().changePage(1);
  }

  void _onSendKiss() {
    final data = Get.find<WidgetDataService>();
    final partner = data.data.value.partnerName;
    KissSendDialog.show(
      partnerName: partner,
      onSend: () {
        data.sendKiss();
        Get.snackbar(
          'Kiss sent 💋',
          'Your partner will feel the love.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.primaryLight,
          colorText: AppColor.textPrimary,
          margin: const EdgeInsets.all(16),
        );
      },
      onViewDetails: () => Get.toNamed(Routes.KISS_SUMMARY),
    );
  }
}
