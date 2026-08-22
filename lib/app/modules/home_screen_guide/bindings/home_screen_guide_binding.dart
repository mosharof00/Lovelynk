import 'package:get/get.dart';

import '../controllers/home_screen_guide_controller.dart';



class HomeScreenGuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreenGuideController>(
      () => HomeScreenGuideController(),
    );
  }
}
