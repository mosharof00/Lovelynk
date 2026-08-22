import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global/widgets/widget_setup_guide_page.dart';
import '../controllers/home_screen_guide_controller.dart';

class HomeScreenGuideView extends GetView<HomeScreenGuideController> {
  const HomeScreenGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetSetupGuidePage(
      steps: controller.steps,
      currentIndex: controller.currentIndex,
      onContinue: controller.onContinue,
    );
  }
}
