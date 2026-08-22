import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global/widgets/widget_setup_guide_page.dart';
import '../controllers/home_screen_guid_controller.dart';

class HomeScreenGuidView extends GetView<HomeScreenGuidController> {
  const HomeScreenGuidView({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetSetupGuidePage(
      steps: controller.steps,
      currentIndex: controller.currentIndex,
      onContinue: controller.onContinue,
    );
  }
}
