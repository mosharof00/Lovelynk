import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Eager put so setupApp / permission dialog always run.
    Get.put<SplashController>(SplashController());
  }
}
