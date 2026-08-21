import 'package:get/get.dart';

import '../controllers/lock_screen_guid_controller.dart';

class LockScreenGuidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LockScreenGuidController>(
      () => LockScreenGuidController(),
    );
  }
}
