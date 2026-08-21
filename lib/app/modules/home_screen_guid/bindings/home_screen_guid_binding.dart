import 'package:get/get.dart';

import '../controllers/home_screen_guid_controller.dart';

class HomeScreenGuidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenGuidController>(
      () => HomeScreenGuidController(),
    );
  }
}
