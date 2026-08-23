import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import 'interactive_send_dialog.dart';

/// Kiss send dialog — hero uses [Assets.images.kissImage].
class KissSendDialog {
  KissSendDialog._();

  static Future<void> show({
    required String partnerName,
    required VoidCallback onSend,
    required VoidCallback onViewDetails,
  }) {
    return InteractiveSendDialog.show(
      title: 'Send a Kiss',
      message: 'Tap the button to send a kiss to $partnerName 💞',
      sendLabel: 'Send a Kiss',
      partnerName: partnerName,
      widgetLabel: 'Kiss',
      tipEmoji: '💋',
      onSend: () {
        Get.back();
        onSend();
      },
      onViewDetails: () {
        Get.back();
        onViewDetails();
      },
      hero: Assets.images.kissImage.image(
        width: 128.w,
        height: 110.w,
        fit: BoxFit.contain,
      ),
    );
  }
}
