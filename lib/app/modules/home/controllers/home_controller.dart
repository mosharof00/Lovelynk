import 'package:get/get.dart';

import '../../../core/services/subscription_service.dart';
import '../../../routes/app_pages.dart';
import '../../main_page/controllers/main_page_controller.dart';

class HomeController extends GetxController {
  /// Mock partner connection for Phase 1 UI. Toggle to preview both layouts.
  final isConnected = true.obs;
  bool isFadeInAnimate = true;

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

  late final SubscriptionService _subscription;

  /// Central subscription access — reads from [SubscriptionService], not duplicated here.
  SubscriptionService get subscription => _subscription;

  bool get isPremium => _subscription.isPremium;

  bool get isWidgetsUnlocked => _subscription.isWidgetsUnlocked;

  void goConnectPartner() => Get.toNamed(Routes.CONNECT_WITH_PARTNER);

  void goWidgetsTab() => Get.find<MainPageController>().changePage(1);

  void goSubscriptions() => Get.toNamed(Routes.SUBSCRIPTIONS);

  /// Dev / UI preview: flip between solo and connected home.
  void toggleConnectedPreview() => isConnected.toggle();

  Future<void> closeFadeInAnimate() async {
    await Future.delayed(Duration(seconds: 6));
    isFadeInAnimate = false;
  }

  /// Called on home load — later fetches user + subscription from Supabase.
  Future<void> loadUser() async {
    // TODO(Supabase): fetch user profile and call
    // _subscription.applyFromUser(...)
    await _subscription.refreshFromUser();
  }

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
    loadUser();
    closeFadeInAnimate();
  }
}
