import 'package:get/get.dart';

import '../controllers/kiss_summary_controller.dart';

class KissSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KissSummaryController>(
      () => KissSummaryController(),
    );
  }
}
