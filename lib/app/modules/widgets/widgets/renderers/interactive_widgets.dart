import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/widget_data_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';

WidgetDataService get _service => Get.find<WidgetDataService>();

// ── Heartbeat (partner count) ───────────────────────────────────────

class HeartbeatWidget extends StatelessWidget {
  const HeartbeatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = _service.heartbeatsFromPartner.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            Assets.icons.heartbeatIcon,
            size: 40.sp,
            color: AppColor.primary,
          ),
          6.verticalSpace,
          AppText(
            '$count',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
              height: 1.0,
            ),
          ),
          2.verticalSpace,
          AppText(
            'from partner',
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }
}

// ── Kiss (partner count) ────────────────────────────────────────────

class KissWidget extends StatelessWidget {
  const KissWidget({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = _service.kissesFromPartner.value;
      final content = Column(
        mainAxisAlignment: compact
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          AppSvgIcon(
            Assets.icons.kissIcon,
            size: compact ? 22.sp : 40.sp,
            color: AppColor.primary,
          ),
          if (!compact) SizedBox(height: 6.h),
          AppText(
            '$count',
            style: TextStyle(
              fontSize: compact ? 18.sp : 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
              height: 1.0,
            ),
          ),
          if (!compact) SizedBox(height: 6.h),
          AppText(
            'from partner',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 9.sp : 11.sp,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      );
      return compact ? SizedBox.expand(child: content) : content;
    });
  }
}

// ── Emoji (partner recent) ──────────────────────────────────────────

class EmojiWidget extends StatelessWidget {
  const EmojiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recent = _service.emojisFromPartner.take(3).toList();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final emoji in recent) ...[
                Text(emoji, style: TextStyle(fontSize: 26.sp)),
                6.horizontalSpace,
              ],
            ],
          ),
          6.verticalSpace,
          AppText(
            'from partner',
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }
}
