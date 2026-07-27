import 'package:get/get.dart';

import '../controllers/color_customise_controller.dart';

class ColorCustomiseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ColorCustomiseController>(
      () => ColorCustomiseController(),
    );
  }
}
