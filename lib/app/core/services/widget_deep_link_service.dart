import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../data/models/widget_models/app_widget_type.dart';
import '../../data/widget_catalog/widget_catalog.dart';
import '../../modules/main_page/controllers/main_page_controller.dart';
import '../../modules/widgets/controllers/widgets_controller.dart';
import '../../routes/app_pages.dart';
import '../utils/logger.dart';

/// Handles `lovelynk://widget/{heartbeat|kiss|emoji}` taps from native widgets.
class WidgetDeepLinkService extends GetxService {
  Future<WidgetDeepLinkService> init() async {
    HomeWidget.widgetClicked.listen(_handleUri);
    final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initial != null) {
      // Defer until main shell is ready.
      Future.delayed(const Duration(milliseconds: 600), () => _handleUri(initial));
    }
    return this;
  }

  void _handleUri(Uri? uri) {
    if (uri == null || uri.scheme != 'lovelynk') return;

    final action = uri.host == 'widget' && uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : null;
    if (action == null) return;

    final type = switch (action) {
      'heartbeat' => AppWidgetType.heartbeat,
      'kiss' => AppWidgetType.kiss,
      'emoji' => AppWidgetType.emoji,
      _ => null,
    };
    if (type == null) return;

    Log.i('[WidgetDeepLink] Opened from widget — $action');
    _navigateThenSend(type);
  }

  Future<void> _navigateThenSend(AppWidgetType type) async {
    if (Get.currentRoute != Routes.MAIN_PAGE) {
      await Get.offAllNamed(Routes.MAIN_PAGE);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    if (Get.isRegistered<MainPageController>()) {
      Get.find<MainPageController>().changePage(1);
    }
    await Future.delayed(const Duration(milliseconds: 250));

    if (!Get.isRegistered<WidgetsController>()) return;
    final def = WidgetCatalog.byType(type);
    if (def != null) {
      Get.find<WidgetsController>().onSendTap(def);
    }
  }
}
