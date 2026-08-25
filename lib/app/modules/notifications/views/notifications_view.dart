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
            onTap: controller.markAllRead,
          ),
        ],
      ),
      body: Obx(() {
        final list = controller.items;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 44.sp,
                    color: AppColor.hintText,
                  ),
                  12.verticalSpace,
                  AppText(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  6.verticalSpace,
                  AppText(
                    'Updates about visits, anniversaries, and your account will appear here.',
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
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
          itemCount: list.length,
          separatorBuilder: (_, __) => 10.verticalSpace,
          itemBuilder: (context, index) {
            final n = list[index];
            return _NotificationCard(
              notification: n,
              timeLabel: controller.timeLabel(n.at),
              categoryLabel: controller.categoryLabel(n.category),
              onTap: () => controller.onTapNotification(n),
            );
          },
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
      case NotificationCategory.relationship:
        return Icons.favorite_border_rounded;
      case NotificationCategory.account:
        return Icons.person_outline_rounded;
      case NotificationCategory.subscription:
        return Icons.workspace_premium_outlined;
      case NotificationCategory.system:
        return Icons.info_outline_rounded;
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
                child: Icon(_icon, size: 20.sp, color: AppColor.primary),
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
            ],
          ),
        ),
      ),
    );
  }
}
