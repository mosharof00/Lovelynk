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
}
