import 'package:get/get.dart';

import '../controllers/partner_profile_controller.dart';

class PartnerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerProfileController>(() => PartnerProfileController());
  }
}
