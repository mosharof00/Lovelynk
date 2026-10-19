import 'dart:async';

import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/couple_editor.dart';
import '../../../core/utils/time_zone_utils.dart';
import '../../../core/services/compass_service.dart';
import '../../../core/services/location_sync_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/services/user_prefs_service.dart';
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
  final userAvatarPath = RxnString();
  final partnerAvatarPath = RxnString();

  // Location & distance observables
  final distanceLabel = '0'.obs;
  final isTogether = false.obs;
  final isPartnerLocationPaused = false.obs;
  final isMyLocationPaused = false.obs;
  final hasLocationPermission = true.obs;
  final isLocationServiceDisabled = false.obs;
  final locationLastUpdated = RxnString();

  String get distanceUnit => UserPrefsService.to.distanceUnit.value.shortLabel;

  final greeting = 'Hello,'.obs;

  /// Null = no anniversary set.
  final daysTogether = RxnInt();

  /// Null = no upcoming visit; 0 = today.
  final nextVisitInDays = RxnInt();
  final partnerTime = RxnString();
  final partnerCity = RxnString();
  final kissesSent = '0'.obs;

  RxBool get isOffline => SessionService.to.lastLoadFailed;
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

  void goPartnerProfile() => Get.toNamed(Routes.PARTNER_PROFILE);

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
    userAvatarPath.value = data?.user.avatarPath;
    isConnected.value = couple != null;
    partnerName.value = couple?.partner.displayName ?? '';
    partnerAvatarPath.value = couple?.partner.avatarPath;

    final liveCity = data?.partnerLive?.location?.city?.trim();
    final tzCity = TimeZoneUtils.cityFromTimezone(couple?.partner.timezone);
    partnerCity.value = (liveCity != null && liveCity.isNotEmpty) ? liveCity : tzCity;

    _updateClock();
    _updateDistance();
  }

  /// Calculates distance label, checks proximity, and evaluates permission/sharing states.
  void _updateDistance() {
    if (!isConnected.value) {
      distanceLabel.value = '0';
      isTogether.value = false;
      return;
    }

    final locService = Get.isRegistered<LocationSyncService>()
        ? LocationSyncService.to
        : null;

    if (locService != null) {
      isLocationServiceDisabled.value = !locService.isServiceEnabled.value;
      hasLocationPermission.value = locService.hasPermission;
      isMyLocationPaused.value = !locService.isSharingEnabled.value;
    }

    final session = SessionService.to;
    final partnerSharing = session.isPartnerLocationSharingEnabled;
    isPartnerLocationPaused.value = !partnerSharing;

    final partnerLive = session.partnerLive;
    final updated = partnerLive?.location?.updatedAt;
    if (updated != null) {
      locationLastUpdated.value = timeAgo(updated);
    } else {
      locationLastUpdated.value = null;
    }

    final compass = Get.isRegistered<CompassService>() ? CompassService.to : null;
    final meters = compass?.partnerDistanceMeters.value;

    if (meters != null) {
      if (meters < 80) {
        isTogether.value = true;
        distanceLabel.value = 'Together';
      } else {
        isTogether.value = false;
        final unit = UserPrefsService.to.distanceUnit.value;
        final dist = unit == DistanceUnit.miles
            ? meters / 1609.344
            : meters / 1000.0;
        final formatter = NumberFormat('#,###');
        distanceLabel.value = formatter.format(dist.round());
      }
    } else if (partnerLive?.distanceKm != null) {
      final km = partnerLive!.distanceKm!;
      if (km < 0.08) {
        isTogether.value = true;
        distanceLabel.value = 'Together';
      } else {
        isTogether.value = false;
        final unit = UserPrefsService.to.distanceUnit.value;
        final dist = unit.fromKilometers(km);
        final formatter = NumberFormat('#,###');
        distanceLabel.value = formatter.format(dist.round());
      }
    } else {
      distanceLabel.value = '--';
      isTogether.value = false;
    }
  }

  /// Tapping the distance chip allows fixing permission errors or opening settings.
  Future<void> onDistanceChipTapped() async {
    if (!isConnected.value) {
      goConnectPartner();
      return;
    }
    final loc = Get.isRegistered<LocationSyncService>()
        ? LocationSyncService.to
        : null;
    if (loc == null) return;

    if (!loc.isServiceEnabled.value) {
      Get.snackbar(
        'GPS Services Disabled',
        'Please turn on Location Services in your device settings to calculate distance.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.blackText.withValues(alpha: 0.9),
        colorText: AppColor.white,
        margin: EdgeInsets.all(16.w),
        mainButton: TextButton(
          onPressed: () => loc.openLocationSettings(),
          child: const Text('Settings', style: TextStyle(color: AppColor.primary)),
        ),
      );
      await loc.openLocationSettings();
      return;
    }

    if (loc.isDeniedForever) {
      Get.snackbar(
        'Location Permission Denied',
        'Location access is permanently disabled. Please allow location access in iOS Settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.blackText.withValues(alpha: 0.9),
        colorText: AppColor.white,
        margin: EdgeInsets.all(16.w),
        mainButton: TextButton(
          onPressed: () => loc.openAppSettings(),
          child: const Text('Settings', style: TextStyle(color: AppColor.primary)),
        ),
      );
      await loc.openAppSettings();
      return;
    }

    if (!loc.hasPermission) {
      final granted = await loc.requestPermission();
      if (!granted) {
        Get.snackbar(
          'Location Permission Needed',
          'LoveLynk requires location access to calculate distance and compass heading to your partner.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.blackText.withValues(alpha: 0.9),
          colorText: AppColor.white,
          margin: EdgeInsets.all(16.w),
        );
      }
      _updateDistance();
      return;
    }

    if (isMyLocationPaused.value) {
      Get.snackbar(
        'Location Sharing Paused',
        'You have paused your location sharing. You can resume sharing anytime in Settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.blackText.withValues(alpha: 0.9),
        colorText: AppColor.white,
        margin: EdgeInsets.all(16.w),
      );
      return;
    }

    if (isPartnerLocationPaused.value) {
      final partner = partnerName.value.isEmpty ? 'Your partner' : partnerName.value;
      Get.snackbar(
        'Partner Sharing Paused',
        '$partner has currently paused their location sharing.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColor.blackText.withValues(alpha: 0.9),
        colorText: AppColor.white,
        margin: EdgeInsets.all(16.w),
      );
      return;
    }
  }

  /// Day counts, partner clock and greeting; re-run every 30s so they roll
  /// over at midnight without a reload.
  void _updateClock() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final couple = SessionService.to.couple;

    final since = couple?.togetherSince;
    daysTogether.value = since == null
        ? null
        : today.difference(DateTime(since.year, since.month, since.day)).inDays;

    final visit = couple?.nextVisitAt?.toLocal();
    final visitDay =
        visit == null ? null : DateTime(visit.year, visit.month, visit.day);
    nextVisitInDays.value = visitDay == null || visitDay.isBefore(today)
        ? null
        : visitDay.difference(today).inDays;

    final partner = couple?.partner;
    final clock = partner == null
        ? null
        : TimeZoneUtils.wallClock(
            timezone: partner.timezone,
            utcOffsetMinutes: partner.utcOffsetMinutes,
          );
    partnerTime.value =
        clock == null ? null : DateFormat('h:mm a').format(clock);

    greeting.value = switch (now.hour) {
      >= 5 && < 12 => 'Good morning,',
      >= 12 && < 17 => 'Good afternoon,',
      >= 17 && < 22 => 'Good evening,',
      _ => 'Hello,',
    };
  }

  Future<void> onRefresh() async {
    final session = SessionService.to;
    try {
      await session.load();
      if (Get.isRegistered<LocationSyncService>()) {
        await LocationSyncService.to.syncCurrentLocation(force: true);
      }
    } catch (e) {
      Log.w('Home: refresh failed: $e');
    }
    _updateClock();
    _updateDistance();
  }

  void editAnniversary(BuildContext context) =>
      CoupleEditor.editAnniversary(context);

  void editNextVisit(BuildContext context) =>
      CoupleEditor.nextVisitActions(context);

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

    // Update distance when compass bearing/distance or distance unit changes
    if (Get.isRegistered<CompassService>()) {
      _workers.add(
        ever(CompassService.to.partnerDistanceMeters, (_) => _updateDistance()),
      );
    }
    _workers.add(
      ever(UserPrefsService.to.distanceUnit, (_) => _updateDistance()),
    );

    if (Get.isRegistered<LocationSyncService>()) {
      _workers.add(
        ever(LocationSyncService.to.permission, (_) => _updateDistance()),
      );
      _workers.add(
        ever(LocationSyncService.to.isServiceEnabled, (_) => _updateDistance()),
      );
      _workers.add(
        ever(LocationSyncService.to.isSharingEnabled, (_) => _updateDistance()),
      );
    }

    _coupleSub = session.coupleEvents.listen(_onCoupleEvent);

    _clockTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateClock(),
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
