import 'package:get/get.dart';

import '../../../core/utils/helper_utils.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  //TODO: Implement SplashController

  Future<void> setupApp() async {
    await Future.delayed(Duration(seconds: 2));

    navigateToScreen();
  }

  Future<void> navigateToScreen() async {
    bool isLoggedIn = await HelperUtils.checkLoginStatus().timeout(
      const Duration(seconds: 5),
    );

    if (isLoggedIn) {
      await HelperUtils.initMainControllers();
      Get.offAllNamed(Routes.MAIN_PAGE);
    } else {
      Get.offAllNamed(Routes.MAIN_PAGE);
    }
  }

  @override
  void onInit() {
    setupApp();
    super.onInit();
  }
}
