import 'dart:math' as math;

import 'package:bulkretail/app/global/widgets/initials_avatar.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../controllers/home_controller.dart';

/// Shared arc geometry (fractions of the connection [Size]).
class _ArcGeom {
  static const startX = 0.18;
  static const endX = 0.82;
  static const endY = 0.42;
  static const controlY = -0.08;

  /// Peak of the quadratic bezier at t = 0.5.
  static Offset peak(Size size) {
    final start = Offset(size.width * startX, size.height * endY);
    final end = Offset(size.width * endX, size.height * endY);
    final control = Offset(size.width * 0.5, size.height * controlY);
    return start * 0.25 + control * 0.5 + end * 0.25;
  }
}

/// Home connection card — avatars + arc + center status + bottom logo.
class PartnerDistanceCard extends GetView<HomeController> {
  const PartnerDistanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = controller.isConnected.value;
      Widget chip;

      if (!connected) {
        chip = _LockedChip(unit: controller.distanceUnit);
      } else if (controller.isLocationServiceDisabled.value) {
        chip = _WarningChip(
          icon: Icons.location_off_rounded,
          label: 'GPS Off',
          onTap: controller.onDistanceChipTapped,
        );
      } else if (!controller.hasLocationPermission.value) {
        chip = _WarningChip(
          icon: Icons.near_me_disabled_rounded,
          label: 'Location Needed',
          onTap: controller.onDistanceChipTapped,
        );
      } else if (controller.isMyLocationPaused.value) {
        chip = _WarningChip(
          icon: Icons.pause_circle_outline_rounded,
          label: 'Sharing Paused',
          onTap: controller.onDistanceChipTapped,
        );
      } else if (controller.isPartnerLocationPaused.value) {
        chip = const _WarningChip(
          icon: Icons.pause_circle_filled_rounded,
          label: 'Partner Paused',
        );
      } else if (controller.isTogether.value) {
        chip = _TogetherChip(onTap: controller.onDistanceChipTapped);
      } else {
        chip = _DistanceChip(
          value: controller.distanceLabel.value,
          unit: controller.distanceUnit,
          lastUpdated: controller.locationLastUpdated.value,
          onTap: controller.onDistanceChipTapped,
        );
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColor.inputBorder.withValues(alpha: 0.5),
          ),
        ),
        child: SizedBox(
          height: 90.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final peak = _ArcGeom.peak(size);
              // Center the chip on the arc peak.
              const chipH = 32.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DashedArcPainter(
                        color: AppColor.primary.withValues(alpha: 0.45),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  // Mile / lock chip — dead center of the dotted arc
                  Positioned(
                    left: 0,
                    right: 0,
                    top: peak.dy - chipH / 2,
                    child: Center(child: chip),
                  ),
                  // Logo under the arc / chip
                  Positioned(
                    left: 0,
                    right: 0,
                    top: peak.dy + chipH / 2 + 16.h,
                    child: Center(
                      child: Image.asset(
                        Assets.logos.appLogoSmall.path,
                        height: 40.w,
                        width: 40.w,
                      ),
                    ),
                  ),
                  // Avatars on the sides (labels at bottom)
                  Positioned(
                    left: 0,
                    top: size.height * _ArcGeom.endY - 26.w,
                    child: _AvatarSlot(
                      label: 'You',
                      name: controller.userName.value,
                      avatarPath: controller.userAvatarPath.value,
                      showAdd: false,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: size.height * _ArcGeom.endY - 26.w,
                    child: _AvatarSlot(
                      label: connected
                          ? controller.partnerName.value
                          : 'Add Partner',
                      name: connected ? controller.partnerName.value : '',
                      avatarPath: connected
                          ? controller.partnerAvatarPath.value
                          : null,
                      showAdd: !connected,
                      onTap: connected
                          ? controller.goPartnerProfile
                          : controller.goConnectPartner,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

}

class _LockedChip extends StatelessWidget {
  const _LockedChip({required this.unit});

  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 14.sp, color: AppColor.textPrimary),
          4.horizontalSpace,
          AppText(
            unit,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceChip extends StatelessWidget {
  const _DistanceChip({
    required this.value,
    required this.unit,
    this.lastUpdated,
    this.onTap,
  });

  final String value;
  final String unit;
  final String? lastUpdated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColor.textPrimary,
              ),
            ),
            if (value != '--') ...[
              4.horizontalSpace,
              AppText(
                unit,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
            if (lastUpdated != null) ...[
              6.horizontalSpace,
              Container(
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: AppColor.hintText,
                  shape: BoxShape.circle,
                ),
              ),
              6.horizontalSpace,
              AppText(
                lastUpdated!,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TogetherChip extends StatelessWidget {
  const _TogetherChip({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColor.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, size: 14.sp, color: AppColor.primary),
            6.horizontalSpace,
            AppText(
              'Together',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningChip extends StatelessWidget {
  const _WarningChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13.sp, color: AppColor.textSecondary),
            4.horizontalSpace,
            AppText(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarSlot extends StatelessWidget {
  const _AvatarSlot({
    required this.label,
    required this.name,
    required this.showAdd,
    this.avatarPath,
    this.onTap,
  });

  final String label;
  final String name;
  final String? avatarPath;
  final bool showAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InitialsAvatar(
                  name: name,
                  avatarPath: avatarPath,
                  size: 52.w,
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
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.add, size: 14.sp, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        6.verticalSpace,
        SizedBox(
          width: 72.w,
          child: AppText(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Soft dashed arc between the two avatars (behind the center chip).
class _DashedArcPainter extends CustomPainter {
  _DashedArcPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * _ArcGeom.startX, size.height * _ArcGeom.endY);
    final end = Offset(size.width * _ArcGeom.endX, size.height * _ArcGeom.endY);
    final control = Offset(size.width * 0.5, size.height * _ArcGeom.controlY);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 6.0;
      const gap = 6.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedArcPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
