import 'dart:async';

import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import '../../routes/app_pages.dart';
import '../utils/logger.dart';
import 'session_service.dart';

/// Handles taps from native home/lock widgets with deep linking.
class WidgetDeepLinkService extends GetxService {
  Future<WidgetDeepLinkService> init() async {
    HomeWidget.widgetClicked.listen(_handleUri);
    final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initial != null) {
      // Delay slightly on cold launch to let GetMaterialApp & session settle
      Future.delayed(
        const Duration(milliseconds: 700),
        () => _handleUri(initial),
      );
    }
    return this;
  }

  void _handleUri(Uri? uri) async {
    if (uri == null || uri.scheme != 'lovelynk') return;

    Log.i('[WidgetDeepLink] Opened from widget — $uri');

    // Wait until SessionService has resolved session (up to 2 seconds)
    if (Get.isRegistered<SessionService>()) {
      final session = SessionService.to;
      int waited = 0;
      while (session.hasSession && session.bootstrap.value == null && waited < 2000) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited += 100;
      }
    }

    final path = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : (uri.host.isNotEmpty && uri.host != 'widget' ? uri.host : '');

    switch (path) {
      case 'heartbeat':
        Get.toNamed(Routes.HEARTBEAT_SUMMARY);
        break;
      case 'kiss':
        Get.toNamed(Routes.KISS_SUMMARY);
        break;
      case 'emoji':
        Get.toNamed(Routes.EMOJI_SUMMARY);
        break;
      case 'activities':
        Get.toNamed(Routes.ACTIVITIES);
        break;
      case 'partner_distance':
      case 'distance':
      case 'love_compass':
      case 'compass':
      case 'partner_weather':
      case 'weather':
      case 'partner_time':
      case 'time':
      case 'days_together':
      case 'together_counter':
      case 'next_visit_countdown':
      case 'next_visit':
      case 'anniversary':
      case 'initials':
        if (SessionService.to.isPaired) {
          Get.toNamed(Routes.PARTNER_PROFILE);
        } else {
          _openApp();
        }
        break;
      default:
        _openApp();
        break;
    }
  }

  Future<void> _openApp() async {
    if (Get.currentRoute != Routes.MAIN_PAGE) {
      await Get.offAllNamed(Routes.MAIN_PAGE);
    }
  }
}
