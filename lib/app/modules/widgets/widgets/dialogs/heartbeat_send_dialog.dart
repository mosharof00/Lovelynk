import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../gen/assets.gen.dart';
import 'interactive_send_dialog.dart';

/// Heartbeat send dialog — hero uses [Assets.images.heartbeatImage].
class HeartbeatSendDialog {
  HeartbeatSendDialog._();

  static Future<void> show({
    required String partnerName,
    required VoidCallback onSend,
    required VoidCallback onViewDetails,
  }) {
    return InteractiveSendDialog.show(
      title: 'Send Heartbeat',
      message: 'Tap the button to send a heartbeat to $partnerName 💞',
      sendLabel: 'Send Heartbeat',
      onSend: () {
        Get.back();
        onSend();
      },
      onViewDetails: () {
        Get.back();
        onViewDetails();
      },
      hero: Assets.images.heartbeatImage.image(
        width: 120.w,
        height: 110.w,
        fit: BoxFit.contain,
      ),
    );
  }
}
