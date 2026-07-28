import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/widget_catalog/widget_catalog.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../../main_page/controllers/main_page_controller.dart';

class WidgetsController extends GetxController {
  late final SubscriptionService _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
  }

  bool get isUnlocked => _subscription.isWidgetsUnlocked;

  List<WidgetDefinition> widgetsFor(WidgetCategory category) =>
      WidgetCatalog.byCategory(category);

  void onAddTap(WidgetDefinition widget) {
    Get.bottomSheet(
      _AddWidgetSheet(
        title: widget.title,
        onCustomise: () {
          Get.back();
          Get.find<MainPageController>().changePage(2);
        },
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void onUnlockTap() {
    Get.dialog(
      AlertDialog(
        title: const AppText('Unlock widgets'),
        content: const AppText(
          'Your free trial unlocks all widgets. After the trial, subscribe to keep them unlocked.',
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const AppText('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _subscription.startTrial();
              Get.back();
              Get.snackbar(
                'Trial started',
                'All widgets are unlocked for 7 days.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColor.primaryLight,
                colorText: AppColor.textPrimary,
              );
            },
            child: AppText(
              'Start free trial',
              style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              _subscription.activateSubscription();
              Get.back();
              Get.snackbar(
                'Subscribed',
                'All widgets unlocked.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColor.primaryLight,
                colorText: AppColor.textPrimary,
              );
            },
            child: AppText(
              'Subscribe',
              style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Dev helper: expire trial to preview locked UI.
  void debugExpireTrial() => _subscription.expireTrial();
}

class _AddWidgetSheet extends StatelessWidget {
  const _AddWidgetSheet({required this.title, required this.onCustomise});

  final String title;
  final VoidCallback onCustomise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppText(
            'Add $title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const AppText(
            'Customise this widget in the app, then add it from your iPhone: long-press the Home or Lock screen → + → Lovelynk.',
            maxLines: 6,
            style: TextStyle(color: AppColor.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          GlobalButton(onTap: onCustomise, text: 'Open Customise'),
        ],
      ),
    );
  }
}
