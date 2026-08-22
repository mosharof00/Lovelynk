import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/widget_models/widget_guide_step.dart';

class LockScreenGuidController extends GetxController {
  final currentIndex = 0.obs;

  late final List<WidgetGuideStep> steps;

  @override
  void onInit() {
    super.onInit();
    final name = AppConfig.appName;
    steps = [
      WidgetGuideStep(
        imagePath: Assets.images.lockWidgetGuidStep1.path,
        title: 'Press and hold anywhere on your Lock Screen',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.lockWidgetGuidStep2.path,
        title: 'Tap Customize',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.lockWidgetGuidStep3.path,
        title: 'Tap Lock Screen',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.lockWidgetGuidStep4.path,
        title: 'Tap Add Widgets, then search for $name',
        helpLabel: "Can't find $name?",
        helpMessage:
            'Tap the area below the clock, then search “$name”. If it doesn’t appear, open the app once and try again.',
      ),
      WidgetGuideStep(
        imagePath: Assets.images.lockWidgetGuidStep5.path,
        title: "Your partner's turn",
        subtitle:
            'Ask your partner to add the same $name widget on their Lock Screen, otherwise live widgets won’t update for both of you.',
        helpLabel: 'Still not working?',
        helpMessage:
            'Both of you need the widget on the Lock Screen and to stay signed in. After adding it, try sending from the app again.',
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
