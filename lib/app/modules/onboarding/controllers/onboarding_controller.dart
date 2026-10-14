import 'package:get/get.dart';

import '../../../core/services/local_store_service.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  void continueToLogin() {
    HiveService.setOnBoardShowed(true);
    Get.offAllNamed(Routes.LOGIN);
  }
}
