import 'package:bulkretail/app/modules/products/controllers/products_controller.dart';
import 'package:bulkretail/app/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

import '../controllers/main_page_controller.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainPageController>(() => MainPageController());
    Get.lazyPut<ProductsController>(() => ProductsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
