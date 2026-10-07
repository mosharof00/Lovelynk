import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_models/session_bootstrap.dart';
import '../../../routes/app_pages.dart';
import '../../main_page/controllers/main_page_controller.dart';

class HomeController extends GetxController {
  /// From [SessionService.bootstrap]; the toggle below is for UI preview only.
  final isConnected = false.obs;
  bool isFadeInAnimate = true;

  final userName = ''.obs;
  final partnerName = ''.obs;
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
    await Future.delayed(Duration(seconds: 3));
    isFadeInAnimate = false;
  }

  Future<void> loadUser() async {
    final session = SessionService.to;
    // Launch bootstrap may have failed offline; retry once here.
    if (session.bootstrap.value == null && session.hasSession) {
      try {
        await session.load();
      } catch (e) {
        Log.w('Home: session bootstrap failed: $e');
      }
    }
    // TODO(RevenueCat): drive SubscriptionService from session.access.
    await _subscription.refreshFromUser();
  }

  void _applySession(SessionBootstrap? data) {
    if (data == null) return;
    userName.value = data.user.firstName;
    isConnected.value = data.isPaired;
    partnerName.value = data.couple?.partner.displayName ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
    final session = SessionService.to;
    _applySession(session.bootstrap.value);
    ever<SessionBootstrap?>(session.bootstrap, _applySession);
    loadUser();
    closeFadeInAnimate();
  }
}
