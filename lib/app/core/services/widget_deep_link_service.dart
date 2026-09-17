import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../routes/app_pages.dart';
import '../utils/logger.dart';

/// Handles taps from native home/lock widgets.
///
/// Interactive widgets only open the app — send flows live on the details screens.
class WidgetDeepLinkService extends GetxService {
  Future<WidgetDeepLinkService> init() async {
    HomeWidget.widgetClicked.listen(_handleUri);
    final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initial != null) {
      Future.delayed(const Duration(milliseconds: 600), () => _handleUri(initial));
    }
    return this;
  }

  void _handleUri(Uri? uri) {
    if (uri == null || uri.scheme != 'lovelynk') return;

    Log.i('[WidgetDeepLink] Opened from widget — $uri');
    _openApp();
  }

  Future<void> _openApp() async {
    if (Get.currentRoute != Routes.MAIN_PAGE) {
      await Get.offAllNamed(Routes.MAIN_PAGE);
    }
  }
}
