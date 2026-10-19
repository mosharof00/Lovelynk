import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/notification_models/app_notification.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        backgroundColor: AppColor.background,
        elevation: 0,
        actions: [
          AppBarAction(
            icon: Icons.done_all_rounded,
            tooltip: 'Mark all read',
            onTap: () => controller.markAllRead(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
            ),
          );
        }

        final list = controller.items;
        if (list.isEmpty) {
          return RefreshIndicator.adaptive(
            onRefresh: controller.refreshNotifications,
            color: AppColor.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            color: AppColor.primaryLight.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 36.sp,
                            color: AppColor.primary,
                          ),
                        ),
                        16.verticalSpace,
                        AppText(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        8.verticalSpace,
                        AppText(
                          'Touches, kisses, emojis, and relationship reminders will appear here.',
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
                ),
              ],
            ),
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: controller.refreshNotifications,
          color: AppColor.primary,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
            itemCount: list.length,
            separatorBuilder: (_, __) => 10.verticalSpace,
            itemBuilder: (context, index) {
              final n = list[index];
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  decoration: BoxDecoration(
                    color: AppColor.error,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColor.white,
                    size: 24.sp,
                  ),
                ),
                onDismissed: (_) => controller.deleteItem(n.id),
                child: _NotificationCard(
                  notification: n,
                  timeLabel: controller.timeLabel(n.at),
                  categoryLabel: controller.categoryLabel(n.category),
                  onTap: () => controller.onTapNotification(n),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.timeLabel,
    required this.categoryLabel,
    required this.onTap,
  });

  final AppNotification notification;
  final String timeLabel;
  final String categoryLabel;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.category) {
      case NotificationCategory.heartbeat:
        return Icons.favorite_rounded;
      case NotificationCategory.kiss:
        return Icons.volunteer_activism_rounded;
      case NotificationCategory.emoji:
        return Icons.sentiment_very_satisfied_rounded;
      case NotificationCategory.relationship:
        return Icons.favorite_border_rounded;
      case NotificationCategory.subscription:
        return Icons.workspace_premium_outlined;
      case NotificationCategory.system:
        return Icons.info_outline_rounded;
      case NotificationCategory.account:
        return Icons.person_outline_rounded;
      case NotificationCategory.announcement:
        return Icons.campaign_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.category) {
      case NotificationCategory.heartbeat:
      case NotificationCategory.kiss:
      case NotificationCategory.relationship:
        return AppColor.primary;
      case NotificationCategory.emoji:
        return const Color(0xFFFFA000);
      case NotificationCategory.subscription:
        return const Color(0xFF7C4DFF);
      case NotificationCategory.announcement:
        return const Color(0xFF00ACC1);
      case NotificationCategory.system:
      case NotificationCategory.account:
        return AppColor.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Material(
      color: unread
          ? AppColor.primaryLight.withValues(alpha: 0.45)
          : AppColor.white,
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
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColor.inputBorder.withValues(alpha: 0.7),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(_icon, size: 20.sp, color: _iconColor),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            notification.title,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(left: 6.w),
                            decoration: const BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    4.verticalSpace,
                    AppText(
                      notification.body,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColor.inputBorder.withValues(alpha: 0.8),
                            ),
                          ),
                          child: AppText(
                            categoryLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: _iconColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
