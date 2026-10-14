import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/session_service.dart';
import '../../../data/models/user_models/session_bootstrap.dart';
import '../../../routes/app_pages.dart';

class PartnerProfileController extends GetxController {
  final name = ''.obs;
  final fullName = ''.obs;
  final nickname = RxnString();
  final avatarPath = RxnString();
  final togetherSince = RxnString();
  final daysTogether = RxnInt();
  final city = RxnString();
  final localTime = RxnString();

  Worker? _sessionWorker;
  Timer? _clock;

  @override
  void onInit() {
    super.onInit();
    final session = SessionService.to;
    _apply(session.bootstrap.value);
    _sessionWorker = ever<SessionBootstrap?>(session.bootstrap, (data) {
      if (data?.couple == null && Get.currentRoute == Routes.PARTNER_PROFILE) {
        Get.back();
        return;
      }
      _apply(data);
    });
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _updateClock());
  }

  void _apply(SessionBootstrap? data) {
    final couple = data?.couple;
    if (couple == null) return;
    final partner = couple.partner;
    name.value = partner.displayName;
    fullName.value = partner.fullName;
    final nick = partner.nickname?.trim();
    nickname.value = nick == null || nick.isEmpty ? null : nick;
    avatarPath.value = partner.avatarPath;

    final since = couple.togetherSince;
    togetherSince.value =
        since == null ? null : DateFormat('d MMMM yyyy').format(since);
    daysTogether.value =
        since == null ? null : DateTime.now().difference(since).inDays;

    city.value = _cityFromTimezone(partner.timezone);
    _updateClock();
  }

  void _updateClock() {
    final offset = SessionService.to.partner?.utcOffsetMinutes;
    localTime.value = offset == null
        ? null
        : DateFormat('h:mm a').format(
            DateTime.now().toUtc().add(Duration(minutes: offset)),
          );
  }

  /// "America/New_York" → "New York".
  static String? _cityFromTimezone(String? tz) {
    if (tz == null || !tz.contains('/')) return null;
    return tz.split('/').last.replaceAll('_', ' ');
  }

  @override
  void onClose() {
    _sessionWorker?.dispose();
    _clock?.cancel();
    super.onClose();
  }
}
