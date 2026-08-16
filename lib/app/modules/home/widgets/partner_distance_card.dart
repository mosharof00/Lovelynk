import 'package:bulkretail/app/core/config/app_config.dart';
import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/utils/helper_utils.dart';
import 'package:bulkretail/app/global/widgets/cached_image.dart';
import 'package:bulkretail/app/global/widgets/global_button.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

class PartnerDistanceCard extends GetView<HomeController> {
  const PartnerDistanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = controller.isConnected.value;
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColor.inputBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _AvatarSlot(
                      label: "You",
                      showAdd: false,
                      imageUrl: HelperUtils.demoProfileImage,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadiusDirectional.circular(
                                20.r,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 1.r),
                                  blurRadius: 1.r,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10.r,
                                  color: connected ? Colors.green : Colors.grey,
                                ),
                                8.width,
                                AppText(
                                  connected ? "Connected" : "Not connected",
                                  style: context.titleSmall,
                                ),
                              ],
                            ),
                          ),
                          6.height,
                          AppText(
                            connected
                                ? '${controller.distanceLabel.value}'
                                : '— — —',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: connected? AppColor.textPrimary: AppColor.grey410,
                            ),
                          ),
                          AppText(
                            connected
                                ? controller.distanceUnit.value
                                : 'miles apart',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.textSecondary,
                            ),
                          ),

                          Image.asset(
                            Assets.images.connectedImage.path,
                            width: 200.w,
                          ),
                        ],
                      ),
                    ),
                    _AvatarSlot(
                      label: connected
                          ? controller.partnerName.value
                          : 'Add Partner',
                      showAdd: !connected,
                      onTap: connected ? null : controller.goConnectPartner,
                      imageUrl: connected
                          ? HelperUtils.partnerDemoProfileImage
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          connected
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColor.inputBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(AppConfig.appLogo, height: 40.w, width: 40.w),
                      4.width,
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "Connect with your partner",
                              style: context.titleSmall,
                            ),
                            4.height,
                            AppText(
                              "Start sharing moments and see your connection come to life",
                              style: context.bodySmall.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      12.width,
                      GlobalButton(
                        onTap: () {},
                        text: "Connect",
                        fontSize: 12.sp,
                        height: 26.h,
                        width: 70.w,
                      ),
                    ],
                  ),
                ),
        ],
      );
    });
  }
}

class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({
    required this.label,
    required this.showAdd,
    this.onTap,
    this.imageUrl,
  });

  final String label;
  final bool showAdd;
  final VoidCallback? onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              imageUrl != null
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.primary.withAlpha(50),
                          width: 1.r,
                        ),
                      ),
                      child: CachedImage(
                        imgUrl: imageUrl ?? '',
                        height: 58.w,
                        width: 58.w,
                        borderRadius: 50.r,
                      ),
                    )
                  : CircleAvatar(
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
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(1, 1),
                          blurRadius: 2.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add,
                      size: 14.sp,
                      color: AppColor.primary,
                    ),
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
      ..quadraticBezierTo(
        size.width / 2,
        size.height,
        size.width,
        size.height / 2,
      );
    canvas.drawPath(path, paint);

    final heart = Paint()..color = AppColor.primary;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.65), 4, heart);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
