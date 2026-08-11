import 'package:flutter/material.dart';
import 'package:bulkretail/app/global/widgets/custom_svg_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../controllers/main_page_controller.dart';

class MainPageView extends GetView<MainPageController> {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.selectedIndex.value]),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNav extends GetView<MainPageController> {
  const _BottomNav();

  static final _tabs = [
    _NavTab(
      outlineIcon: Assets.icons.homeIcon,
      fillIcon: Assets.icons.homeFillIcon,
      label: 'Home',
    ),
    _NavTab(
      outlineIcon: Assets.icons.widgetIcon,
      fillIcon: Assets.icons.widgetFillIcon,
      label: 'Widgets',
    ),
    _NavTab(
      outlineIcon: Assets.icons.adjustmentIcon,
      fillIcon: Assets.icons.adjustmentFillIcon,
      label: 'Customise',
    ),
    _NavTab(
      outlineIcon: Assets.icons.profileIcon,
      fillIcon: Assets.icons.profileFillIcon,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = controller.selectedIndex.value == index;
                return _NavItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => controller.changePage(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single nav item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColor.secondary;
    final Color inactiveColor = Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12.w : 8.w,
          vertical: 4.h,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColor.secondary.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customSvgImage(
              imagePath: isActive ? tab.fillIcon : tab.outlineIcon,
              color: isActive ? activeColor : inactiveColor,
              width: 22.w,
              height: 22.w,
            ),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab data model ────────────────────────────────────────────────────────────

class _NavTab {
  final String outlineIcon;
  final String fillIcon;
  final String label;

  const _NavTab({
    required this.outlineIcon,
    required this.fillIcon,
    required this.label,
  });
}
