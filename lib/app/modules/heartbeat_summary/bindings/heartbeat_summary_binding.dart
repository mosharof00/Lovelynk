import 'package:get/get.dart';

import '../controllers/heartbeat_summary_controller.dart';

class HeartbeatSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HeartbeatSummaryController>(
      () => HeartbeatSummaryController(),
    );
  }
}
