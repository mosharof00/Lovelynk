import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_promo_banners.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F6),
              Color(0xFFF3EEFF),
              AppColor.background,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              children: [
                const ProfileHeader(),
                28.verticalSpace,
                ProfileMenuSection(
                  title: 'About You',
                  titleColor: AppColor.primary,
                  onItemTap: controller.onMenuTap,
                  items: const [
                    ProfileMenuItemData(
                      key: 'about_you',
                      icon: Icons.person_outline_rounded,
                      label: 'About You',
                    ),
                  ],
                ),
                22.verticalSpace,
                ProfileMenuSection(
                  title: 'Your Relationship',
                  titleColor: const Color(0xFFC44B9F),
                  onItemTap: controller.onMenuTap,
                  items: [
                    const ProfileMenuItemData(
                      key: 'partner_profile',
                      icon: Icons.favorite_border_rounded,
                      label: 'Partner Profile',
                    ),
                    ProfileMenuItemData(
                      key: 'anniversary',
                      icon: Icons.calendar_today_outlined,
                      label: 'Our Anniversary',
                      value: controller.anniversary.value,
                    ),
                    const ProfileMenuItemData(
                      key: 'invite_partner',
                      icon: Icons.person_add_alt_1_outlined,
                      label: 'Invite Partner',
                    ),
                    ProfileMenuItemData(
                      key: 'sync_status',
                      icon: Icons.sync_rounded,
                      label: 'Sync Status',
                      value: controller.syncStatus.value,
                      valueColor: AppColor.success,
                      showStatusDot: true,
                    ),
                  ],
                ),
                22.verticalSpace,
                ProfileMenuSection(
                  title: 'Account',
                  titleColor: const Color(0xFF5B6CFF),
                  onItemTap: controller.onMenuTap,
                  items: [
                    const ProfileMenuItemData(
                      key: 'subscription',
                      icon: Icons.grid_view_rounded,
                      label: 'Manage Subscription',
                    ),
                    ProfileMenuItemData(
                      key: 'language',
                      icon: Icons.public_rounded,
                      label: 'Language',
                      value: controller.language.value,
                    ),
                    ProfileMenuItemData(
                      key: 'location',
                      icon: Icons.location_on_outlined,
                      label: 'Location Permission',
                      value: controller.locationPermission.value,
                    ),
                    const ProfileMenuItemData(
                      key: 'notifications',
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                    ),
                  ],
                ),
                22.verticalSpace,
                ProfileMenuSection(
                  title: 'Support',
                  titleColor: const Color(0xFF9B5DE5),
                  onItemTap: controller.onMenuTap,
                  items: const [
                    ProfileMenuItemData(
                      key: 'contact',
                      icon: Icons.mail_outline_rounded,
                      label: 'Contact Us',
                    ),
                    ProfileMenuItemData(
                      key: 'privacy',
                      icon: Icons.verified_user_outlined,
                      label: 'Privacy Policy',
                    ),
                    ProfileMenuItemData(
                      key: 'terms',
                      icon: Icons.description_outlined,
                      label: 'Terms of Use',
                    ),
                    ProfileMenuItemData(
                      key: 'help',
                      icon: Icons.help_outline_rounded,
                      label: 'Help Center',
                    ),
                  ],
                ),
                24.verticalSpace,
                ProfilePromoBanners(
                  onReferTap: controller.onReferTap,
                  onRateTap: controller.onRateTap,
                ),
                12.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
