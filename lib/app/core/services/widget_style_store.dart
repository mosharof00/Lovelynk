import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/widget_models/app_widget_type.dart';
import '../../data/models/widget_models/widget_style.dart';

/// Persists per-widget customise styles in the App Group via home_widget.
/// Flutter and (later) WidgetKit both read from here — no Hive for styles.
class WidgetStyleStore extends GetxService {
  static const appGroupId = 'group.com.lovelynk.app.widgetdemo';

  Future<WidgetStyleStore> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
    return this;
  }

  String _key(AppWidgetType type, String field) => '${type.id}_$field';

  Future<WidgetStyle> load(AppWidgetType type) async {
    final map = <String, String?>{};
    for (final field in const [
      'themeColorId',
      'useBackground',
      'backgroundColorId',
      'font',
      'textSize',
    ]) {
      map[field] = await HomeWidget.getWidgetData<String>(_key(type, field));
    }
    return WidgetStyle.fromStorageMap(map);
  }

  Future<void> save(AppWidgetType type, WidgetStyle style) async {
    final map = style.toStorageMap();
    for (final entry in map.entries) {
      await HomeWidget.saveWidgetData<String>(_key(type, entry.key), entry.value);
    }
    // Production widgets will call updateWidget with the real iOS kind name.
    // Demo LoveWidget refresh is harmless if present.
    try {
      await HomeWidget.updateWidget(iOSName: 'LoveWidget');
    } catch (_) {
      // Ignore when extension isn't available (e.g. some platforms).
    }
  }

  Future<void> reset(AppWidgetType type) async {
    await save(type, WidgetStyle.defaults());
  }
}
