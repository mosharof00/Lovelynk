import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/services/widget_data_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/widget_catalog/widget_catalog.dart';
import '../../../routes/app_pages.dart';
import '../widgets/dialogs/emoji_send_dialog.dart';
import '../widgets/dialogs/heartbeat_send_dialog.dart';
import '../widgets/dialogs/how_to_add_widget_sheet.dart';
import '../widgets/dialogs/kiss_send_dialog.dart';

class WidgetsController extends GetxController {
  late final SubscriptionService _subscription;
  late final WidgetDataService _data;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  /// `null` = All categories
  final selectedCategory = Rxn<WidgetCategory>();

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
    _data = Get.find<WidgetDataService>();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  SubscriptionService get subscription => _subscription;

  bool get isUnlocked => _subscription.state.value.isWidgetsUnlocked;

  void selectFilter(WidgetCategory? category) {
    selectedCategory.value = category;
  }

  void onSeeAll(WidgetCategory category) {
    selectedCategory.value = category;
  }

  List<WidgetDefinition> get filteredWidgets {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    return WidgetCatalog.all.where((w) {
      final matchesCategory = category == null || w.category == category;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return w.title.toLowerCase().contains(query) ||
          w.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  List<WidgetDefinition> widgetsFor(WidgetCategory category) {
    final query = searchQuery.value.toLowerCase();
    return WidgetCatalog.byCategory(category).where((w) {
      if (query.isEmpty) return true;
      return w.title.toLowerCase().contains(query) ||
          w.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  /// Categories currently visible under the All filter (after search).
  List<WidgetCategory> get visibleCategories {
    final selected = selectedCategory.value;
    if (selected != null) return [selected];
    return WidgetCategory.values
        .where((c) => widgetsFor(c).isNotEmpty)
        .toList();
  }

  void onAddTap(WidgetDefinition widget) {
    HowToAddWidgetSheet.show();
  }

  /// Interactive footer "Send …" → branded send dialog.
  void onSendTap(WidgetDefinition widget) {
    final partner = _data.data.value.partnerName;

    switch (widget.type) {
      case AppWidgetType.heartbeat:
        HeartbeatSendDialog.show(
          partnerName: partner,
          onSend: () {
            _data.sendHeartbeat();
            _toast(
              'Heartbeat sent 💗',
              'Let them know you\'re thinking of them.',
            );
          },
          onViewDetails: () => Get.toNamed(Routes.HEARTBEAT_SUMMARY),
        );
        break;
      case AppWidgetType.kiss:
        KissSendDialog.show(
          partnerName: partner,
          onSend: () {
            _data.sendKiss();
            _toast('Kiss sent 💋', 'Your partner will feel the love.');
          },
          onViewDetails: () => Get.toNamed(Routes.KISS_SUMMARY),
        );
        break;
      case AppWidgetType.emoji:
        EmojiSendDialog.show(
          partnerName: partner,
          onSend: (emoji) {
            _data.sendEmoji(emoji);
            _toast('Emoji sent $emoji', 'Sent to your partner.');
          },
          onViewDetails: () => Get.toNamed(Routes.EMOJI_SUMMARY),
        );
        break;
      default:
        break;
    }
  }

  void _toast(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.primaryLight,
      colorText: AppColor.textPrimary,
      margin: const EdgeInsets.all(16),
    );
  }

  void onUnlockTap() => Get.toNamed(Routes.SUBSCRIPTIONS);

  /// Dev helper: expire trial to preview locked UI.
  void debugExpireTrial() => _subscription.expireTrial();
}
