import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class HomeStatsRow extends GetView<HomeController> {
  const HomeStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = controller.isConnected.value;
      final items = [
        _StatItem(
          icon: Icons.favorite_rounded,
          value: connected ? controller.daysTogether.value : '— —',
          label: 'days',
          title: 'Days Together',
        ),
        _StatItem(
          icon: Icons.flight_takeoff_rounded,
          value: connected ? controller.nextVisitDays.value : '— —',
          label: 'days to go',
          title: 'Next Visit',
        ),
        _StatItem(
          icon: Icons.schedule_rounded,
          value: connected ? controller.partnerTime.value.split(' ').first : '— —',
          label: connected ? controller.partnerTime.value.split(' ').last : '— —',
          title: 'Partner Time',
        ),
        _StatItem(
          icon: Icons.favorite_border_rounded,
          value: connected ? controller.kissesSent.value : '— —',
          label: 'kisses',
          title: 'Kisses Sent',
        ),
      ];

      return Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) 8.horizontalSpace,
            Expanded(child: _StatCard(item: items[i])),
          ],
        ],
      );
    });
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.title,
  });

  final IconData icon;
  final String value;
  final String label;
  final String title;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.inputBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(item.icon, size: 16.sp, color: AppColor.primary),
          6.verticalSpace,
          AppText(
            item.value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
            ),
          ),
          AppText(
            item.label,
            maxLines: 1,
            style: TextStyle(fontSize: 9.sp, color: AppColor.textSecondary),
          ),
          4.verticalSpace,
          AppText(
            item.title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.sp, color: AppColor.hintText),
          ),
        ],
      ),
    );
  }
}
