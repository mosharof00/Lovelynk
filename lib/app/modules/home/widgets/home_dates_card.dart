import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

/// Paired only: days together, next visit and the partner's local time.
/// Unset dates show "Set date" and open the editor.
class HomeDatesCard extends GetView<HomeController> {
  const HomeDatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isConnected.value) return const SizedBox.shrink();

      final days = controller.daysTogether.value;
      final visit = controller.nextVisitInDays.value;
      final time = controller.partnerTime.value;

      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Row(
          children: [
            Expanded(
              child: _DateTile(
                icon: Icons.favorite_rounded,
                label: 'Together',
                value: days == null ? null : '$days',
                unit: days == 1 ? 'day' : 'days',
                onTap: () => controller.editAnniversary(context),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: _DateTile(
                icon: Icons.flight_takeoff_rounded,
                label: 'Next visit',
                value: visit == null ? null : (visit == 0 ? 'Today' : '$visit'),
                unit: visit == null || visit == 0
                    ? ''
                    : (visit == 1 ? 'day' : 'days'),
                onTap: () => controller.editNextVisit(context),
              ),
            ),
            8.horizontalSpace,
            Expanded(
              child: _DateTile(
                icon: Icons.schedule_rounded,
                label: controller.partnerCity.value ?? 'Their time',
                value: time ?? '--',
                unit: '',
                onTap: controller.goPartnerProfile,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.onTap,
  });

  final IconData icon;
  final String label;

  /// Null shows a "Set date" prompt.
  final String? value;
  final String unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == null;
    return Material(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 84.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColor.inputBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14.sp, color: AppColor.primary),
                  4.horizontalSpace,
                  Expanded(
                    child: AppText(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (isEmpty)
                AppText(
                  'Set date',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                )
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        value!,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        3.horizontalSpace,
                        AppText(
                          unit,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
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
