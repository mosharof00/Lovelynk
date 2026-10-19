import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/services/user_prefs_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../../../global/widgets/global_button.dart';
import '../../profile/widgets/profile_menu_section.dart';
import '../../../data/models/notification_models/app_notification.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Settings',
        showBackButton: true,
        backgroundColor: AppColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          children: [
            Obx(
              () => ProfileMenuSection(
                title: 'Preferences',
                titleColor: AppColor.textSecondary,
                items: [
                  ProfileMenuItemData(
                    icon: Icons.straighten_rounded,
                    label: 'Distance unit',
                    value: controller.distanceUnit.value.label,
                    onTap: () => _showUnitSheet(),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.thermostat_rounded,
                    label: 'Temperature unit',
                    value: controller.temperatureUnit.value.label,
                    onTap: () => _showTempUnitSheet(),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.location_on_outlined,
                    label: 'Share location with partner',
                    hideChevron: true,
                    trailing: Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: controller.isLocationSharing.value,
                        activeThumbColor: AppColor.primary,
                        activeTrackColor: AppColor.primary.withValues(alpha: 0.5),
                        onChanged: (val) => controller.toggleLocationSharing(val),
                      ),
                    ),
                  ),
                  if (!controller.hasLocationPermission)
                    ProfileMenuItemData(
                      icon: Icons.near_me_disabled_rounded,
                      label: 'Location permission',
                      value: 'Fix in Settings',
                      valueColor: AppColor.error,
                      onTap: () => controller.openLocationPermissionSettings(),
                    ),
                  ProfileMenuItemData(
                    icon: Icons.notifications_none_rounded,
                    label: 'Push notifications',
                    value: controller.notifPrefsSummary,
                    onTap: () => _showNotificationPreferencesSheet(context),
                  ),
                ],
              ),
            ),
            22.verticalSpace,
            ProfileMenuSection(
              title: 'Account',
              titleColor: AppColor.textSecondary,
              items: [
                ProfileMenuItemData(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: controller.email,
                ),
                ProfileMenuItemData(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                  onTap: () => _showChangePasswordSheet(context),
                ),
              ],
            ),
            22.verticalSpace,
            Obx(
              () => ProfileMenuSection(
                title: 'About',
                titleColor: AppColor.textSecondary,
                items: [
                  ProfileMenuItemData(
                    icon: Icons.info_outline_rounded,
                    label: 'App version',
                    value: controller.appVersion.value,
                  ),
                ],
              ),
            ),
            32.verticalSpace,
            Center(
              child: TextButton.icon(
                onPressed: () => _showDeleteSheet(context),
                icon: Icon(
                  Icons.delete_forever_outlined,
                  color: AppColor.error,
                  size: 20.sp,
                ),
                label: AppText(
                  'Delete Account',
                  style: context.bodyLarge.copyWith(
                    color: AppColor.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitSheet() {
    _openSheet(
      title: 'Distance unit',
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final unit in DistanceUnit.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  controller.setDistanceUnit(unit);
                  Get.back();
                },
                title: AppText(
                  unit.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                trailing: controller.distanceUnit.value == unit
                    ? Icon(Icons.check_rounded, color: AppColor.primary)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  void _showTempUnitSheet() {
    _openSheet(
      title: 'Temperature unit',
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final unit in TemperatureUnit.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  controller.setTemperatureUnit(unit);
                  Get.back();
                },
                title: AppText(
                  '${unit.label} (${unit.symbol})',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                trailing: controller.temperatureUnit.value == unit
                    ? Icon(Icons.check_rounded, color: AppColor.primary)
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    controller.resetPasswordForm();
    _openSheet(
      title: 'Change password',
      child: Form(
        key: controller.passwordFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasswordInputField(
              controller: controller.currentPasswordController,
              hintText: 'Current password',
              prefixIcon: _lockIcon,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Current password is required' : null,
            ),
            12.verticalSpace,
            PasswordInputField(
              controller: controller.newPasswordController,
              hintText: 'New password',
              prefixIcon: _lockIcon,
              validator: (v) {
                if (v == null || v.isEmpty) return 'New password is required';
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                if (v == controller.currentPasswordController.text) {
                  return 'Choose a different password';
                }
                return null;
              },
            ),
            12.verticalSpace,
            PasswordInputField(
              controller: controller.confirmPasswordController,
              hintText: 'Confirm new password',
              prefixIcon: _lockIcon,
              validator: (v) => v != controller.newPasswordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            20.verticalSpace,
            Obx(
              () => GlobalButton(
                text: 'Update Password',
                onTap: controller.changePassword,
                isLoading: controller.isChangingPassword.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSheet(BuildContext context) {
    controller.deleteConfirmController.clear();
    _openSheet(
      title: 'Delete account?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'This permanently deletes your account, profile photo and support '
            'requests, and disconnects you from your partner. This cannot be undone.\n\n'
            'Active App Store subscriptions are not cancelled automatically — '
            'manage them in iPhone Settings → Apple ID → Subscriptions.',
            maxLines: 10,
            style: context.bodyMedium.copyWith(
              color: AppColor.textSecondary,
              height: 1.4,
            ),
          ),
          16.verticalSpace,
          AppInputTextFormField(
            controller: controller.deleteConfirmController,
            hintText: 'Type ${SettingsController.deleteKeyword} to confirm',
          ),
          20.verticalSpace,
          Obx(
            () => GlobalButton(
              text: 'Delete my account',
              color: AppColor.error,
              onTap: controller.deleteAccount,
              isDisabled: !controller.canDelete.value,
              isLoading: controller.isDeleting.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _lockIcon => Icon(
        Icons.lock_outline_rounded,
        color: AppColor.hintText,
        size: 20.sp,
      );

  void _openSheet({required String title, required Widget child}) {
    Get.bottomSheet(
      Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    16.verticalSpace,
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showNotificationPreferencesSheet(BuildContext context) {
    _openSheet(
      title: 'Notification preferences',
      child: Obx(() {
        if (controller.isLoadingNotifPrefs.value &&
            controller.notifPrefs.value == null) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: const Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              ),
            ),
          );
        }

        final p =
            controller.notifPrefs.value ?? const NotificationPreferences();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              'Notification Categories',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textSecondary,
              ),
            ),
            10.verticalSpace,
            _buildPrefSwitch(
              label: 'Heartbeat touches',
              subtitle: 'When your partner sends you a heartbeat vibration',
              value: p.pushHeartbeat,
              onChanged: (val) =>
                  controller.updatePreference(pushHeartbeat: val),
            ),
            _buildPrefSwitch(
              label: 'Kisses sent',
              subtitle: 'When your partner blows you a kiss',
              value: p.pushKiss,
              onChanged: (val) => controller.updatePreference(pushKiss: val),
            ),
            _buildPrefSwitch(
              label: 'Emoji reactions',
              subtitle: 'When your partner sends you reaction emojis',
              value: p.pushEmoji,
              onChanged: (val) => controller.updatePreference(pushEmoji: val),
            ),
            _buildPrefSwitch(
              label: 'Relationship updates',
              subtitle: 'Anniversaries, visit reminders, and milestones',
              value: p.pushRelationship,
              onChanged: (val) =>
                  controller.updatePreference(pushRelationship: val),
            ),
            _buildPrefSwitch(
              label: 'Subscriptions & billing',
              subtitle: 'Trial alerts, renewal reminders, and receipts',
              value: p.pushSubscription,
              onChanged: (val) =>
                  controller.updatePreference(pushSubscription: val),
            ),
            _buildPrefSwitch(
              label: 'Announcements & tips',
              subtitle: 'Feature updates and relationship tips',
              value: p.pushAnnouncements,
              onChanged: (val) =>
                  controller.updatePreference(pushAnnouncements: val),
            ),
            14.verticalSpace,
            const Divider(),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Quiet Hours',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      3.verticalSpace,
                      AppText(
                        'Silently refresh widgets without alert banners or sound.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                12.horizontalSpace,
                Transform.scale(
                  scale: 0.85,
                  child: Switch.adaptive(
                    value: p.hasQuietHours,
                    activeThumbColor: AppColor.primary,
                    activeTrackColor: AppColor.primary.withValues(alpha: 0.5),
                    onChanged: (val) {
                      if (val) {
                        controller.updatePreference(
                          quietHoursStart: '22:00',
                          quietHoursEnd: '07:00',
                        );
                      } else {
                        controller.updatePreference(clearQuietHours: true);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (p.hasQuietHours) ...[
              12.verticalSpace,
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColor.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColor.inputBorder.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimePickerButton(
                      context: context,
                      label: 'Start time',
                      timeStr: p.quietHoursStart ?? '22:00',
                      onTimePicked: (newTime) {
                        controller.updatePreference(
                            quietHoursStart: newTime);
                      },
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16.sp,
                      color: AppColor.hintText,
                    ),
                    _buildTimePickerButton(
                      context: context,
                      label: 'End time',
                      timeStr: p.quietHoursEnd ?? '07:00',
                      onTimePicked: (newTime) {
                        controller.updatePreference(quietHoursEnd: newTime);
                      },
                    ),
                  ],
                ),
              ),
            ],
            16.verticalSpace,
          ],
        );
      }),
    );
  }

  Widget _buildPrefSwitch({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                2.verticalSpace,
                AppText(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColor.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          8.horizontalSpace,
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              activeThumbColor: AppColor.primary,
              activeTrackColor: AppColor.primary.withValues(alpha: 0.5),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton({
    required BuildContext context,
    required String label,
    required String timeStr,
    required ValueChanged<String> onTimePicked,
  }) {
    final parts = timeStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );
        if (picked != null) {
          final hh = picked.hour.toString().padLeft(2, '0');
          final mm = picked.minute.toString().padLeft(2, '0');
          onTimePicked('$hh:$mm');
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
              ),
            ),
            2.verticalSpace,
            AppText(
              timeStr,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

