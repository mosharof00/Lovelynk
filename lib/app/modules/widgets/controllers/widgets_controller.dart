import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/widget_catalog/widget_catalog.dart';
import '../../../routes/app_pages.dart';
import '../widgets/dialogs/how_to_add_widget_sheet.dart';

class WidgetsController extends GetxController {
  late final SubscriptionService _subscription;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  /// `null` = All categories
  final selectedCategory = Rxn<WidgetCategory>();

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
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

  /// Interactive footer "Send …" → widget details screen (send happens there).
  void onSendTap(WidgetDefinition widget) {
    switch (widget.type) {
      case AppWidgetType.heartbeat:
        Get.toNamed(Routes.HEARTBEAT_SUMMARY);
        break;
      case AppWidgetType.kiss:
        Get.toNamed(Routes.KISS_SUMMARY);
        break;
      case AppWidgetType.emoji:
        Get.toNamed(Routes.EMOJI_SUMMARY);
        break;
      default:
        break;
    }
  }

  void onUnlockTap() => Get.toNamed(Routes.SUBSCRIPTIONS);

  /// Dev helper: expire trial to preview locked UI.
  void debugExpireTrial() => _subscription.expireTrial();
}
