import 'package:get/get.dart';

import '../controllers/lock_screen_guide_controller.dart';

class LockScreenGuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LockScreenGuideController>(
      () => LockScreenGuideController(),
    );
  }
}
