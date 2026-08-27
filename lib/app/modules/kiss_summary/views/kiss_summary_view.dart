import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/reaction_activity.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/kiss_summary_controller.dart';

class KissSummaryView extends GetView<KissSummaryController> {
  const KissSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Kiss',
        subtitle: "Send a kiss to show your love 💋",
        subtitleStyle: context.textTheme.bodySmall?.copyWith(
          color: AppColor.textPrimary.withAlpha(150),
          fontWeight: FontWeight.w500,
        ),
        showBackButton: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _KissHeader(),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Today',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      14.verticalSpace,
                      const _ActivityList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KissHeader extends GetView<KissSummaryController> {
  const _KissHeader();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return SizedBox(
      width: double.infinity,
      height: 290.h + topPad * 0.25,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Assets.images.kissSummaryHeaderImage.image(
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned(
            left: 0,
            right: MediaQuery.of(context).size.width * 0.34,
            top: 112.h,
            child: Obx(
              () => _CountOverlay(
                count: controller.fromPartner,
                label: 'from ${controller.partnerName}',
                color: AppColor.primary,
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.34,
            right: 0,
            top: 112.h,
            child: Obx(
              () => _CountOverlay(
                count: controller.fromMe,
                label: 'from Me',
                color: AppColor.secondary,
              ),
            ),
          ),
          Positioned(
            left: 50.w,
            right: 50.w,
            bottom: 20.h,
            child: GlobalButton(
              onTap: controller.sendKiss,
              text: '',
              height: 40.h,
              widget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '💋',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                  6.width,
                  AppText(
                    'Send Kiss',
                    style: context.titleLarge.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountOverlay extends StatelessWidget {
  const _CountOverlay({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          '$count',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        74.verticalSpace,
        AppText(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.2), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityList extends GetView<KissSummaryController> {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.todayActivity;
      if (items.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Center(
            child: AppText(
              'No kisses yet today.\nSend the first one!',
              textAlign: TextAlign.center,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _ActivityTile(item: items[i]),
            if (i != items.length - 1) 10.verticalSpace,
          ],
        ],
      );
    });
  }
}

class _ActivityTile extends GetView<KissSummaryController> {
  const _ActivityTile({required this.item});

  final ReactionActivity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56.w,
          child: AppText(
            controller.timeLabel(item.at),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: const BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 2, height: 48.h, color: AppColor.primaryLight),
          ],
        ),
        12.horizontalSpace,
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: item.isFromMe
                      ? AppColor.secondary.withValues(alpha: 0.2)
                      : AppColor.primaryLight,
                  child: AppText(
                    item.senderName.isNotEmpty
                        ? item.senderName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: item.isFromMe
                          ? AppColor.secondary
                          : AppColor.primary,
                    ),
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: AppText(
                    item.senderName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                Text('💋', style: TextStyle(fontSize: 16.sp)),
                4.horizontalSpace,
                AppText(
                  'x ${item.count}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
