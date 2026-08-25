import 'package:get/get.dart';

import '../controllers/emoji_summary_controller.dart';

class EmojiSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmojiSummaryController>(
      () => EmojiSummaryController(),
    );
  }
}
