import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global/widgets/widget_setup_guide_page.dart';
import '../controllers/lock_screen_guid_controller.dart';

class LockScreenGuidView extends GetView<LockScreenGuidController> {
  const LockScreenGuidView({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetSetupGuidePage(
      steps: controller.steps,
      currentIndex: controller.currentIndex,
      onContinue: controller.onContinue,
    );
  }
}
