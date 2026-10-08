import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/session_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/services/widget_data_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user_models/session_bootstrap.dart';
import '../../../data/models/widget_models/reaction_activity.dart';
import '../../../global/widgets/global_snackbar.dart';
import '../../../routes/app_pages.dart';
import '../../main_page/controllers/main_page_controller.dart';

/// One line in Home → Recent Activity.
class HomeActivityItem {
  const HomeActivityItem({required this.text, required this.at});

  final String text;
  final DateTime at;
}

class HomeController extends GetxController {
  /// Paired state from [SessionService]; every card reacts to it.
  final isConnected = false.obs;
  bool isFadeInAnimate = true;

  final userName = ''.obs;
  final partnerName = ''.obs;

  // Defaults until location / interactions are connected.
  final distanceLabel = '0'.obs;
  final distanceUnit = 'miles apart'.obs;
  final daysTogether = '0'.obs;
  final nextVisitDays = '--'.obs;
  final partnerTime = '--'.obs;
  final partnerCity = ''.obs;
  final kissesSent = '0'.obs;
  final affirmation =
      'Distance means so little when someone means so much.'.obs;

  late final SubscriptionService _subscription;
  late final WidgetDataService _widgetData;
  Timer? _clockTimer;
  StreamSubscription<CoupleEvent>? _coupleSub;
  final _workers = <Worker>[];

  SubscriptionService get subscription => _subscription;

  bool get isPremium => _subscription.isPremium;

  bool get isWidgetsUnlocked => _subscription.isWidgetsUnlocked;

  void goConnectPartner() => Get.toNamed(Routes.CONNECT_WITH_PARTNER);

  void goWidgetsTab() => Get.find<MainPageController>().changePage(1);

  void goSubscriptions() => Get.toNamed(Routes.SUBSCRIPTIONS);

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

  /// Latest 3 interactions across heartbeat / kiss / emoji, newest first.
  List<HomeActivityItem> get recentActivity {
    final partner = partnerName.value.isEmpty ? 'Your partner' : partnerName.value;

    String describe(ReactionActivity a, String singular, String plural) {
      final what = a.count == 1 ? 'a $singular' : '${a.count} $plural';
      return a.isFromMe ? 'You sent $what' : '$partner sent you $what';
    }

    final items = <HomeActivityItem>[
      for (final a in _widgetData.kissActivity)
        HomeActivityItem(text: describe(a, 'kiss', 'kisses'), at: a.at),
      for (final a in _widgetData.heartbeatActivity)
        HomeActivityItem(text: describe(a, 'heartbeat', 'heartbeats'), at: a.at),
      for (final a in _widgetData.emojiActivity)
        HomeActivityItem(
          text: a.isFromMe
              ? 'You sent ${a.emoji ?? 'an emoji'}'
              : '$partner sent you ${a.emoji ?? 'an emoji'}',
          at: a.at,
        ),
    ]..sort((a, b) => b.at.compareTo(a.at));

    return items.take(3).toList();
  }

  String timeAgo(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _applySession(SessionBootstrap? data) {
    final couple = data?.couple;
    userName.value = data?.user.firstName ?? '';
    isConnected.value = couple != null;
    partnerName.value = couple?.partner.displayName ?? '';

    final since = couple?.togetherSince ?? couple?.createdAt;
    daysTogether.value =
        since == null ? '0' : '${DateTime.now().difference(since).inDays}';

    final visit = couple?.nextVisitAt;
    nextVisitDays.value = visit == null || visit.isBefore(DateTime.now())
        ? '--'
        : '${visit.difference(DateTime.now()).inDays}';

    partnerCity.value = _widgetData.data.value.partnerCity;
    _updatePartnerClock();
  }

  void _updatePartnerClock() {
    final partner = SessionService.to.partner;
    final offset = partner?.utcOffsetMinutes;
    partnerTime.value = offset == null
        ? '--'
        : DateFormat('h:mm a').format(
            DateTime.now().toUtc().add(Duration(minutes: offset)),
          );
  }

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<SubscriptionService>();
    _widgetData = Get.find<WidgetDataService>();

    final session = SessionService.to;
    _applySession(session.bootstrap.value);
    _workers
      ..add(ever<SessionBootstrap?>(session.bootstrap, _applySession))
      ..add(ever<int>(_widgetData.kissesFromMe, (v) => kissesSent.value = '$v'));
    kissesSent.value = '${_widgetData.kissesFromMe.value}';

    _coupleSub = session.coupleEvents.listen(_onCoupleEvent);

    _clockTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updatePartnerClock(),
    );

    loadUser();
    closeFadeInAnimate();
  }

  void _onCoupleEvent(CoupleEvent event) {
    switch (event) {
      case CoupleEvent.left:
        globalSnackBar(
          title: 'Disconnected',
          message: 'You are no longer connected with your partner.',
        );
        break;
      case CoupleEvent.paired:
        // The Connect screen shows its own "All set" dialog.
        if (Get.currentRoute == Routes.CONNECT_WITH_PARTNER) return;
        globalSnackBar(
          title: 'Connected 💞',
          message: 'You are now connected with ${partnerName.value}.',
        );
        break;
    }
  }

  @override
  void onClose() {
    _coupleSub?.cancel();
    _clockTimer?.cancel();
    for (final w in _workers) {
      w.dispose();
    }
    super.onClose();
  }
}
