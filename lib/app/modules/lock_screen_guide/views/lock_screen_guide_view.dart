import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global/widgets/widget_setup_guide_page.dart';
import '../controllers/lock_screen_guide_controller.dart';

class LockScreenGuideView extends GetView<LockScreenGuideController> {
  const LockScreenGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetSetupGuidePage(
      steps: controller.steps,
      currentIndex: controller.currentIndex,
      onContinue: controller.onContinue,
    );
  }
}
