import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../main_page/controllers/main_page_controller.dart';

class HomeController extends GetxController {
  /// Mock partner connection for Phase 1 UI. Toggle to preview both layouts.
  final isConnected = false.obs;

  final userName = 'Jasper'.obs;
  final partnerName = 'Milla'.obs;
  final distanceLabel = '168'.obs;
  final distanceUnit = 'miles apart'.obs;
  final daysTogether = '83'.obs;
  final nextVisitDays = '17'.obs;
  final partnerTime = '8:42 PM'.obs;
  final partnerCity = 'Sydney'.obs;
  final kissesSent = '247'.obs;
  final affirmation =
      'Distance means so little when someone means so much.'.obs;

  void goConnectPartner() => Get.toNamed(Routes.CONNECT_WITH_PARTNER);

  void goWidgetsTab() => Get.find<MainPageController>().changePage(1);

  /// Dev / UI preview: flip between solo and connected home.
  void toggleConnectedPreview() => isConnected.toggle();
}
