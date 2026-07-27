import 'package:get/get.dart';

import '../controllers/connect_with_partner_controller.dart';

class ConnectWithPartnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectWithPartnerController>(
      () => ConnectWithPartnerController(),
    );
  }
}
