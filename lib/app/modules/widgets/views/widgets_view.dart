import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/widgets_controller.dart';
import '../widgets/widget_category_section.dart';

class WidgetsView extends GetView<WidgetsController> {
  const WidgetsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Widgets',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  16.verticalSpace,
                  const _WidgetSearchBar(),
                  14.verticalSpace,
                  const _WidgetFilterChips(),
                  const _TrialBanner(),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final unlocked = controller.isUnlocked;
                final selected = controller.selectedCategory.value;
                final categories = controller.visibleCategories;

                if (controller.filteredWidgets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: AppText(
                        'No widgets found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
                  children: [
                    for (final category in categories) ...[
                      WidgetCategorySection(
                        category: category,
                        widgets: controller.widgetsFor(category),
                        isUnlocked: unlocked,
                        onAdd: controller.onAddTap,
                        onUnlock: controller.onUnlockTap,
                        onSend: controller.onSendTap,
                        showSeeAll: selected == null,
                        onSeeAll: () => controller.onSeeAll(category),
                      ),
                      24.verticalSpace,
                    ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrialBanner extends GetView<WidgetsController> {
  const _TrialBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isUnlocked) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColor.primaryLight,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: AppText(
            'Trial ended — widgets are locked. Unlock to continue.',
            maxLines: 2,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }
}

class _WidgetSearchBar extends GetView<WidgetsController> {
  const _WidgetSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller.searchController,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColor.primary,
        decoration: InputDecoration(
          hintText: 'Search widgets',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: AppColor.hintText,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: AppColor.primary,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: () {
                controller.searchController.clear();
              },
              icon: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppColor.hintText,
              ),
            );
          }),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
        ),
      ),
    );
  }
}

class _WidgetFilterChips extends GetView<WidgetsController> {
  const _WidgetFilterChips();

  static const _chipBg = Color(0xFFE8EDF8);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isActive: selected == null,
              onTap: () => controller.selectFilter(null),
            ),
            8.horizontalSpace,
            for (final category in WidgetCategory.values) ...[
              _FilterChip(
                label: category.title,
                isActive: selected == category,
                onTap: () => controller.selectFilter(category),
              ),
              8.horizontalSpace,
            ],
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isActive ? AppColor.secondary : _WidgetFilterChips._chipBg,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColor.textPrimary,
          ),
        ),
      ),
    );
  }
}
