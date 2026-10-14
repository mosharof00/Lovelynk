import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/handle_exceptions.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../data/models/user_models/session_bootstrap.dart';
import '../../../data/repositories/couple_repository.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final ICoupleRepository _coupleRepository = Get.find<ICoupleRepository>();

  bool isFadeInAnimate = true;

  final userName = ''.obs;
  final isPaired = false.obs;
  final partnerName = ''.obs;
  final anniversary = ''.obs;
  final isDisconnecting = false.obs;
  Worker? _sessionWorker;

  void onProfileTap() {
    // TODO: open edit profile
  }

  void onReferTap() {
    // TODO: open referral
  }

  void onRateTap() {
    // TODO: open App Store rating
  }

  void onInvitePartnerTap() => Get.toNamed(Routes.CONNECT_WITH_PARTNER);

  void onDisconnectTap(BuildContext context) {
    final partner = partnerName.value.isEmpty ? 'your partner' : partnerName.value;
    DialogUtils.showDialog(
      context: context,
      dialogType: DialogType.warning,
      title: 'Disconnect partner?',
      description:
          'You and $partner will stop sharing heartbeats, kisses, location and widgets. '
          'If you reconnect with $partner within 30 days, your history comes back.',
      okText: 'Disconnect',
      cancelText: 'Cancel',
      okOnPress: _disconnect,
    );
  }

  Future<void> _disconnect() async {
    if (isDisconnecting.value) return;
    isDisconnecting.value = true;
    try {
      final session = await _coupleRepository.leaveCouple();
      SessionService.to.apply(session);
    } catch (e) {
      handleException(e, context: 'Disconnect partner');
    } finally {
      isDisconnecting.value = false;
    }
  }

  Future<void> onLogoutTap(BuildContext context) async {
    DialogUtils.showDialog(
      context: context,
      title: 'Logout',
      description: 'Are you sure you want to logout from lovelynk?',
      okText: 'Logout',
      cancelText: 'Cancel',
      okOnPress: () async {
        await SessionService.to.signOut();
        await HelperUtils.deleteMainControllers();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  void _applySession(SessionBootstrap? data) {
    final couple = data?.couple;
    userName.value = data?.user.fullName ?? '';
    isPaired.value = couple != null;
    partnerName.value = couple?.partner.displayName ?? '';
    final since = couple?.togetherSince;
    anniversary.value =
        since == null ? 'Not set' : DateFormat('d MMM yyyy').format(since);
  }

  Future<void> closeFadeInAnimate() async {
    await Future.delayed(Duration(seconds: 1));
    isFadeInAnimate = false;
  }

  @override
  void onInit() {
    super.onInit();
    final session = SessionService.to;
    _applySession(session.bootstrap.value);
    _sessionWorker = ever<SessionBootstrap?>(session.bootstrap, _applySession);
    closeFadeInAnimate();
  }

  @override
  void onClose() {
    _sessionWorker?.dispose();
    super.onClose();
  }
}
