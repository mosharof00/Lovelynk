import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/home_controller.dart';

class PartnerDistanceCard extends GetView<HomeController> {
  const PartnerDistanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = controller.isConnected.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColor.inputBorder.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _AvatarSlot(
                  label: connected ? 'You' : 'Add Partner',
                  showAdd: !connected,
                  onTap: connected ? null : controller.goConnectPartner,
                ),
                Expanded(
                  child: Column(
                    children: [
                      AppText(
                        connected
                            ? '${controller.distanceLabel.value}'
                            : '— — —',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      AppText(
                        connected ? controller.distanceUnit.value : 'miles apart',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      8.verticalSpace,
                      CustomPaint(
                        size: Size(double.infinity, 20.h),
                        painter: _HeartLinePainter(),
                      ),
                    ],
                  ),
                ),
                _AvatarSlot(
                  label: connected ? controller.partnerName.value : 'Add Partner',
                  showAdd: !connected,
                  onTap: connected ? null : controller.goConnectPartner,
                ),
              ],
            ),
            if (connected) ...[
              12.verticalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.secondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: AppText(
                  'Connected with ${controller.partnerName.value}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColor.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              16.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.background2,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, color: AppColor.primary, size: 22.sp),
                    10.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Connect with your partner',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          AppText(
                            'Start sharing moments and see how far love can travel.',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.horizontalSpace,
                    SizedBox(
                      width: 110.w,
                      child: GlobalButton(
                        onTap: controller.goConnectPartner,
                        text: 'Connect Now',
                        height: 36.h,
                        fontSize: 11.sp,
                        color: AppColor.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({
    required this.label,
    required this.showAdd,
    this.onTap,
  });

  final String label;
  final bool showAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: AppColor.primaryLight,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColor.primary.withValues(alpha: 0.7),
                  size: 28.sp,
                ),
              ),
              if (showAdd)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, size: 14.sp, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        6.verticalSpace,
        SizedBox(
          width: 64.w,
          child: AppText(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _HeartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.primary.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height / 2);
    canvas.drawPath(path, paint);

    final heart = Paint()..color = AppColor.primary;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.65), 4, heart);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
