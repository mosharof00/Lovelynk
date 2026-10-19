import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/handle_exceptions.dart';
import '../../../core/services/location_sync_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/user_prefs_service.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../global/widgets/global_snackbar.dart';
import '../../../routes/app_pages.dart';

class SettingsController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();
  final IUserRepository _userRepository = Get.find<IUserRepository>();

  final appVersion = ''.obs;

  final passwordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isChangingPassword = false.obs;

  final deleteConfirmController = TextEditingController();
  final canDelete = false.obs;
  final isDeleting = false.obs;

  static const deleteKeyword = 'DELETE';

  Rx<DistanceUnit> get distanceUnit => UserPrefsService.to.distanceUnit;

  String get email => SessionService.to.user?.email ?? '';

  bool get hasLocationSync => Get.isRegistered<LocationSyncService>();
  RxBool get isLocationSharing => hasLocationSync
      ? LocationSyncService.to.isSharingEnabled
      : true.obs;
  bool get hasLocationPermission =>
      hasLocationSync && LocationSyncService.to.hasPermission;
  String get locationStatusText =>
      hasLocationSync ? LocationSyncService.to.statusMessage : '';

  Future<void> toggleLocationSharing(bool value) async {
    if (!hasLocationSync) return;
    try {
      await LocationSyncService.to.setSharingEnabled(value);
      globalSnackBar(
        title: value ? 'Location sharing active' : 'Location sharing paused',
        message: value
            ? 'Your partner can now see your distance and compass direction.'
            : 'Your location is hidden from your partner.',
      );
    } catch (e) {
      handleException(e, context: 'Location sharing');
    }
  }

  Future<void> openLocationPermissionSettings() async {
    if (!hasLocationSync) return;
    await LocationSyncService.to.openAppSettings();
  }

  @override
  void onInit() {
    super.onInit();
    deleteConfirmController.addListener(() {
      canDelete.value = deleteConfirmController.text.trim() == deleteKeyword;
    });
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  void setDistanceUnit(DistanceUnit unit) =>
      UserPrefsService.to.setDistanceUnit(unit);

  void resetPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  Future<void> changePassword() async {
    if (isChangingPassword.value) return;
    if (!(passwordFormKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isChangingPassword.value = true;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      Get.back();
      resetPasswordForm();
      globalSnackBar(
        title: 'Password changed',
        message: 'Use your new password next time you sign in.',
      );
    } catch (e) {
      handleException(e, context: 'Change password');
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (isDeleting.value || !canDelete.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isDeleting.value = true;
    try {
      await _userRepository.deleteAccount();
      await SessionService.to.onAccountDeleted();
      await HelperUtils.deleteMainControllers();
      Get.offAllNamed(Routes.LOGIN);
      globalSnackBar(
        title: 'Account deleted',
        message: 'Your account and data have been removed.',
      );
    } catch (e) {
      isDeleting.value = false;
      handleException(e, context: 'Delete account');
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    deleteConfirmController.dispose();
    super.onClose();
  }
}
