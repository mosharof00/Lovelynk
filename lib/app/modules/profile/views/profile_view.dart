import 'package:bulkretail/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_promo_banners.dart';
import '../widgets/profile_subscription_banner.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
          children: [
            const ProfileHeader(),
            16.verticalSpace,
            const ProfileSubscriptionBanner(),
            22.verticalSpace,
            ProfileMenuSection(
              title: 'Account',
              titleColor: AppColor.textSecondary,
              items: [
                ProfileMenuItemData(
                  icon: Icons.edit,
                  label: 'Edit Profile',
                ),
                ProfileMenuItemData(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => Get.toNamed(Routes.NOTIFICATIONS),
                ),
              ],
            ),
            22.verticalSpace,
            ProfileMenuSection(
              title: 'Your Relationship',
              titleColor: AppColor.textSecondary,
              items: [
                const ProfileMenuItemData(
                  icon: Icons.favorite_border_rounded,
                  label: 'Partner Profile',
                ),
                ProfileMenuItemData(
                  icon: Icons.calendar_today_outlined,
                  label: 'Our Anniversary',
                  value: controller.anniversary.value,
                ),
                ProfileMenuItemData(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Invite Partner',
                  onTap: () => Get.toNamed(Routes.CONNECT_WITH_PARTNER),
                ),
              ],
            ),
            22.verticalSpace,
            ProfileMenuSection(
              title: 'Widgets & Activity',
              titleColor: AppColor.textSecondary,
              items: [
                ProfileMenuItemData(
                  icon: Icons.history_rounded,
                  label: 'Activities',
                  onTap: () => Get.toNamed(Routes.ACTIVITIES),
                ),
                ProfileMenuItemData(
                  icon: Icons.favorite_rounded,
                  label: 'Heartbeat',
                  onTap: () => Get.toNamed(Routes.HEARTBEAT_SUMMARY),
                ),
                ProfileMenuItemData(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'Kiss',
                  onTap: () => Get.toNamed(Routes.KISS_SUMMARY),
                ),
                ProfileMenuItemData(
                  icon: Icons.emoji_emotions_outlined,
                  label: 'Emoji',
                  onTap: () => Get.toNamed(Routes.EMOJI_SUMMARY),
                ),
              ],
            ),
            22.verticalSpace,
            ProfileMenuSection(
              title: 'Support',
              titleColor: AppColor.textSecondary,
              items: const [
                ProfileMenuItemData(
                  icon: Icons.mail_outline_rounded,
                  label: 'Contact Us',
                ),
                ProfileMenuItemData(
                  icon: Icons.verified_user_outlined,
                  label: 'Privacy Policy',
                ),
                ProfileMenuItemData(
                  icon: Icons.description_outlined,
                  label: 'Terms of Use',
                ),
              ],
            ),
            24.verticalSpace,
            ProfilePromoBanners(
              onReferTap: controller.onReferTap,
              onRateTap: controller.onRateTap,
            ),
            18.verticalSpace,
            _ProfileLogoutSection(
              onTap: () => controller.onLogoutTap(context),
            ),
            12.verticalSpace,
          ],
        ),
      ),
    );
  }
}

class _ProfileLogoutSection extends StatelessWidget {
  const _ProfileLogoutSection({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColor.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColor.error,
                  size: 18.sp,
                ),
              ),
              14.horizontalSpace,
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.error,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: AppColor.hintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
