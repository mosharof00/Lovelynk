import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../global/widgets/app_text.dart';
import '../../global/widgets/global_button.dart';
import '../../routes/app_pages.dart';
import '../services/session_service.dart';
import '../theme/app_color.dart';

/// Gate for anything that needs a connected partner (sending or viewing
/// heartbeats, kisses, emojis, activity, distance…).
class PartnerGuard {
  PartnerGuard._();

  /// True when paired. Otherwise shows the "connect first" prompt.
  static bool ensurePaired() {
    if (SessionService.to.isPaired) return true;
    showPrompt();
    return false;
  }

  /// Navigates to [route] only when paired.
  static void open(String route, {dynamic arguments}) {
    if (ensurePaired()) Get.toNamed(route, arguments: arguments);
  }

  /// Runs [action] only when paired.
  static void run(VoidCallback action) {
    if (ensurePaired()) action();
  }

  static void showPrompt() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(const _ConnectPartnerDialog(), barrierDismissible: true);
  }
}

class _ConnectPartnerDialog extends StatelessWidget {
  const _ConnectPartnerDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: AppColor.primary,
                size: 30.sp,
              ),
            ),
            14.verticalSpace,
            AppText(
              'Connect with your partner first',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            10.verticalSpace,
            AppText(
              'Heartbeats, kisses, emojis and your shared activity unlock once you and your partner are connected.',
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary,
                height: 1.4,
              ),
            ),
            22.verticalSpace,
            GlobalButton(
              text: 'Connect now',
              height: 42.h,
              onTap: () {
                Get.back();
                Get.toNamed(Routes.CONNECT_WITH_PARTNER);
              },
            ),
            4.verticalSpace,
            TextButton(
              onPressed: () => Get.back(),
              child: AppText(
                'Maybe later',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
