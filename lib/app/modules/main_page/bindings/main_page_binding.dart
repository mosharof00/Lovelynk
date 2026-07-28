import 'package:get/get.dart';

import '../../color_customise/controllers/color_customise_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../widgets/controllers/widgets_controller.dart';
import '../controllers/main_page_controller.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainPageController>(() => MainPageController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<WidgetsController>(() => WidgetsController());
    Get.lazyPut<ColorCustomiseController>(() => ColorCustomiseController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
