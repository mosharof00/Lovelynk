import 'package:bulkretail/app/core/extensions/sizedbox_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/services/compass_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/utils/helper_utils.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Wait until the first frame so Get.dialog has a real overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupApp();
    });
  }

  Future<void> setupApp() async {
    await Future.delayed(const Duration(milliseconds: 600));
    await _askPermissions();
    await Future.delayed(const Duration(milliseconds: 400));
    await navigateToScreen();
  }

  /// Soft pre-prompt before the system permission sheet.
  Future<void> _askPermissions() async {
    final accepted = await Get.dialog<bool>(
      const _PermissionDialog(),
      barrierDismissible: false,
    );

    if (accepted == true && Get.isRegistered<CompassService>()) {
      await Get.find<CompassService>().requestAndStartLocation();
    }
  }

  Future<void> navigateToScreen() async {
    final isLoggedIn = await HelperUtils.checkLoginStatus().timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );

    if (isLoggedIn) {
      await HelperUtils.initMainControllers();
      Get.offAllNamed(Routes.MAIN_PAGE);
    } else {
      Get.offAllNamed(Routes.ONBOARDING);
    }
  }
}

class _PermissionDialog extends StatelessWidget {
  const _PermissionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 40.sp,
              color: AppColor.primary,
            ),
            14.verticalSpace,
            AppText(
              'Allow permissions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            10.verticalSpace,
            AppText(
              'Lovelynk needs location access for Partner Distance and the Love Compass so they can point toward your partner in real time.',
              textAlign: TextAlign.center,
              maxLines: 6,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textSecondary,
                height: 1.4,
              ),
            ),
            22.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: GlobalButton(
                    onTap: () => Get.back(result: false),
                    text: 'Cancel',
                    height: 40.h,
                    color: Colors.grey,
                  ),
                ),
                12.width,
                Expanded(
                  child: GlobalButton(
                    onTap: () => Get.back(result: true),
                    text: 'Continue',
                    height: 40.h,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
