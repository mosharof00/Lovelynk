import 'package:bulkretail/app/global/widgets/app_svg_icon.dart';
import 'package:bulkretail/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/services/widget_data_service.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';

WidgetDataService get _service => Get.find<WidgetDataService>();

// ── Heartbeat ───────────────────────────────────────────────────────

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

// class _HeartbeatPainter extends CustomPainter {
//   _HeartbeatPainter({required this.color});
//
//   final Color color;
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = StrokeJoin.round;
//
//     final midY = size.height / 2;
//     final path = Path()
//       ..moveTo(0, midY)
//       ..lineTo(size.width * 0.30, midY)
//       ..lineTo(size.width * 0.40, midY - size.height * 0.35)
//       ..lineTo(size.width * 0.50, midY + size.height * 0.45)
//       ..lineTo(size.width * 0.60, midY - size.height * 0.15)
//       ..lineTo(size.width * 0.70, midY)
//       ..lineTo(size.width, midY);
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant _HeartbeatPainter oldDelegate) =>
//       oldDelegate.color != color;
// }

// ── Kiss ────────────────────────────────────────────────────────────

class KissWidget extends StatelessWidget {
  const KissWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('💋', style: TextStyle(fontSize: 48.sp)),
        6.verticalSpace,
        AppText(
          'tap to send',
          style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
        ),
      ],
    );
  }
}

// ── Emoji ───────────────────────────────────────────────────────────

class EmojiWidget extends StatelessWidget {
  const EmojiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recent = _service.sentEmojis.take(3).toList();
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
            'tap to send',
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
        ],
      );
    });
  }
}
