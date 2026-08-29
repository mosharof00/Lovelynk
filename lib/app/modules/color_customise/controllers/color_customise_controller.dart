import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/widget_style_store.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/models/widget_models/widget_style.dart';
import '../../../data/widget_catalog/widget_catalog.dart';

class ColorCustomiseController extends GetxController {
  late final WidgetStyleStore _store;

  final selectedType = AppWidgetType.daysTogether.obs;
  final style = WidgetStyle.defaults().obs;
  final isSaving = false.obs;
  final isLoading = true.obs;

  List<WidgetDefinition> get catalog => WidgetCatalog.all;

  WidgetDefinition get selectedWidget =>
      WidgetCatalog.byType(selectedType.value) ?? WidgetCatalog.all.first;

  Color get themeColor =>
      WidgetStyleOptions.byId(style.value.themeColorId).color;

  Color get backgroundColor =>
      WidgetStyleOptions.byId(style.value.backgroundColorId).color;

  @override
  void onInit() {
    super.onInit();
    _store = Get.find<WidgetStyleStore>();
    loadStyleFor(selectedType.value);
  }

  Future<void> loadStyleFor(AppWidgetType type) async {
    isLoading.value = true;
    selectedType.value = type;
    style.value = await _store.load(type);
    isLoading.value = false;
  }

  void selectWidget(AppWidgetType type) => loadStyleFor(type);

  void setThemeColor(String id) {
    style.value = style.value.copyWith(themeColorId: id);
  }

  void setUseBackground(bool value) {
    style.value = style.value.copyWith(useBackground: value);
  }

  void setBackgroundColor(String id) {
    style.value = style.value.copyWith(backgroundColorId: id);
  }

  void setFont(WidgetSystemFont font) {
    style.value = style.value.copyWith(font: font);
  }

  void setTextSize(WidgetTextSize size) {
    style.value = style.value.copyWith(textSize: size);
  }

  Future<void> saveChanges() async {
    isSaving.value = true;
    try {
      await _store.save(selectedType.value, style.value);
      Get.snackbar(
        'Saved',
        'Style saved for ${selectedWidget.title}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.primaryLight,
        colorText: AppColor.textPrimary,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> resetToDefault() async {
    await _store.reset(selectedType.value);
    style.value = WidgetStyle.defaults();
    Get.snackbar(
      'Reset',
      'Defaults restored for ${selectedWidget.title}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColor.primaryLight,
      colorText: AppColor.textPrimary,
    );
  }
}
