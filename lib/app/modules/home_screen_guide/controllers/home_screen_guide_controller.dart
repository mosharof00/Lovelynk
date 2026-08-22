import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/widget_models/widget_guide_step.dart';

class HomeScreenGuideController extends GetxController {
  final currentIndex = 0.obs;

  late final List<WidgetGuideStep> steps;

  @override
  void onInit() {
    super.onInit();
    final name = AppConfig.appName;
    steps = [
      WidgetGuideStep(
        imagePath: Assets.images.homeWidgetGuidStep1.path,
        title: 'Press and hold anywhere on your Home Screen',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.homeWidgetGuidStep2.path,
        title: 'Tap Edit in the top-left, then tap Add Widget',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.homeWidgetGuidStep3.path,
        title: 'Search for $name',
        helpLabel: "Can't find $name?",
        helpMessage:
            'Widgets appear after $name is installed. Search “$name”. If it still doesn’t show, open the app once, then try Add Widget again.',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.homeWidgetGuidStep4.path,
        title: "Your partner's turn",
        subtitle:
            'Ask your partner to add the same $name widget on their Home Screen. Interactive widgets need both of you to add them.',
        helpLabel: 'Still not working?',
        helpMessage:
            'Both of you should stay signed in and add the widget from the $name gallery. Then try sending from the app again.',
      ),
    ];
  }

  void onContinue() {
    if (currentIndex.value >= steps.length - 1) {
      Get.back();
      return;
    }
    currentIndex.value++;
  }
}
