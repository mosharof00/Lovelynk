import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/widget_models/app_widget_type.dart';
import '../../data/models/widget_models/widget_style.dart';
import '../widgets/widget_app_group.dart';
import '../widgets/widget_sync_service.dart';

/// Persists per-widget customise styles in the App Group.
/// Native refresh is delegated to [WidgetSyncService].
class WidgetStyleStore extends GetxService {
  Future<WidgetStyleStore> init() async {
    await HomeWidget.setAppGroupId(WidgetAppGroup.id);
    return this;
  }

  String _key(AppWidgetType type, String field) =>
      WidgetAppGroup.styleKey(type.id, field);

  Future<WidgetStyle> load(AppWidgetType type) async {
    final map = <String, String?>{};
    for (final field in const [
      WidgetAppGroup.styleThemeColorId,
      WidgetAppGroup.styleUseBackground,
      WidgetAppGroup.styleBackgroundColorId,
      WidgetAppGroup.styleFont,
      WidgetAppGroup.styleTextSize,
    ]) {
      map[field] = await HomeWidget.getWidgetData<String>(_key(type, field));
    }
    return WidgetStyle.fromStorageMap(map);
  }

  Future<void> save(AppWidgetType type, WidgetStyle style) async {
    if (Get.isRegistered<WidgetSyncService>()) {
      await Get.find<WidgetSyncService>().syncStyle(type, style);
    } else {
      final map = style.toStorageMap();
      for (final entry in map.entries) {
        await HomeWidget.saveWidgetData<String>(
          _key(type, entry.key),
          entry.value,
        );
      }
    }
  }

  Future<void> reset(AppWidgetType type) async {
    await save(type, WidgetStyle.defaults());
  }
}
