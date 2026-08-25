import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../controllers/activities_controller.dart';

class ActivitiesView extends GetView<ActivitiesController> {
  const ActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const CustomAppBar(
        title: 'Activities',
        showBackButton: true,
        backgroundColor: AppColor.background,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          8.verticalSpace,
          const _FilterChips(),
          12.verticalSpace,
          Expanded(
            child: Obx(() {
              final items = controller.filteredItems;
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 40.sp,
                          color: AppColor.hintText,
                        ),
                        12.verticalSpace,
                        AppText(
                          'No activity yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        6.verticalSpace,
                        AppText(
                          'Heartbeats, kisses, and emojis you share will show up here.',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColor.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                itemCount: items.length,
                separatorBuilder: (_, __) => 10.verticalSpace,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _ActivityCard(
                    item: item,
                    timeLabel: controller.timeLabel(item.reaction.at),
                    onTap: () => controller.openSummary(item.kind),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends GetView<ActivitiesController> {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: Obx(() {
        final selected = controller.filter.value;
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          children: [
            for (final f in ActivityFilter.values) ...[
              _Chip(
                label: switch (f) {
                  ActivityFilter.all => 'All',
                  ActivityFilter.heartbeat => 'Heartbeat',
                  ActivityFilter.kiss => 'Kiss',
                  ActivityFilter.emoji => 'Emoji',
                },
                selected: selected == f,
                onTap: () => controller.setFilter(f),
              ),
              8.horizontalSpace,
            ],
          ],
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : AppColor.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? AppColor.primary
                : AppColor.inputBorder.withValues(alpha: 0.8),
          ),
        ),
        child: AppText(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColor.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  final ActivityFeedItem item;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reaction = item.reaction;
    final leading = switch (item.kind) {
      ActivityKind.heartbeat => Icons.favorite_rounded,
      ActivityKind.kiss => Icons.volunteer_activism_rounded,
      ActivityKind.emoji => Icons.emoji_emotions_outlined,
    };

    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: reaction.isFromMe
                      ? AppColor.secondary.withValues(alpha: 0.15)
                      : AppColor.primaryLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: item.kind == ActivityKind.emoji
                    ? Text(
                        reaction.emoji ?? '😊',
                        style: TextStyle(fontSize: 20.sp),
                      )
                    : item.kind == ActivityKind.kiss
                        ? Text('💋', style: TextStyle(fontSize: 18.sp))
                        : Icon(leading, color: AppColor.primary, size: 20.sp),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.headline,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    4.verticalSpace,
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryLight.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: AppText(
                            item.kindLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        AppText(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColor.hintText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: AppColor.hintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
