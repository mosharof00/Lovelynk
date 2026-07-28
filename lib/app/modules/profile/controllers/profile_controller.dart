import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dialog_utils.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final userName = 'Jasper'.obs;
  final isPremium = true.obs;
  final anniversary = '12 Oct 2022'.obs;
  final language = 'English'.obs;
  final locationPermission = 'Always'.obs;
  final syncStatus = 'All Good'.obs;
  final avatarUrl = ''.obs;

  void onProfileTap() {
    // TODO: open edit profile
  }

  void onMenuTap(String key) {
    // TODO: navigate per menu item
  }

  void onReferTap() {
    // TODO: open referral
  }

  void onRateTap() {
    // TODO: open App Store rating
  }

  Future<void> onLogoutTap(BuildContext context) async {
    DialogUtils.showDialog(
      context: context,
      title: 'Logout',
      description: 'Are you sure you want to logout from lovelynk?',
      okText: 'Logout',
      cancelText: 'Cancel',
      okOnPress: () async {
        await HelperUtils.clearUser();
        await HelperUtils.deleteMainControllers();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}
