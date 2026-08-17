import 'package:get/get.dart';

import '../controllers/glass_test_controller.dart';

class GlassTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GlassTestController>(
      () => GlassTestController(),
    );
  }
}
