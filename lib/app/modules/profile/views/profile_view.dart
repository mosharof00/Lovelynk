import 'package:bulkretail/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/glass_background.dart';
import '../../../global/widgets/glass_card.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_promo_banners.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: GlassBackground(
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
              children: [
                const ProfileHeader(),
                28.verticalSpace,
                ProfileMenuSection(
                  title: 'About You',
                  titleColor: AppColor.textSecondary,
                  items: [
                    ProfileMenuItemData(
                      icon: Icons.person_outline_rounded,
                      label: 'About You',
                      onTap: () => Get.toNamed(Routes.GLASS_TEST),
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
                  title: 'Account',
                  titleColor: AppColor.textSecondary,
                  items: [
                    ProfileMenuItemData(
                      icon: Icons.subscript,
                      label: 'Manage Subscription',
                      onTap: () => Get.toNamed(Routes.SUBSCRIPTIONS),
                    ),
                    ProfileMenuItemData(
                      icon: Icons.public_rounded,
                      label: 'Language',
                      value: controller.language.value,
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
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: BorderRadius.circular(16.r),
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
    );
  }
}
