import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
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
    await Future.delayed(const Duration(milliseconds: 1400));
    await navigateToScreen();
  }

  /// Soft pre-prompt before the system permission sheet.
  /// Skipped when location is already granted.
  Future<void> _askPermissions() async {
    if (!Get.isRegistered<CompassService>()) return;

    final compass = Get.find<CompassService>();
    final status = await Geolocator.checkPermission();

    // Already granted — start listening, never show the soft prompt again.
    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      await compass.requestAndStartLocation();
      return;
    }

    final accepted = await Get.dialog<bool>(
      const _PermissionDialog(),
      barrierDismissible: true,
    );

    // Continue → system permission sheet. Dismiss / back → skip.
    if (accepted == true) {
      await compass.requestAndStartLocation();
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
            GlobalButton(
              onTap: () => Get.back(result: true),
              text: 'Continue',
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }
}
