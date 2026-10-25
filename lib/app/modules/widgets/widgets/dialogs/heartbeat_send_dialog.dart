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
    required void Function(int count) onSend,
  }) {
    return InteractiveSendDialog.show(
      title: 'Send Heartbeat',
      message: 'Choose how many heartbeats to send to $partnerName 💞',
      sendLabel: 'Send Heartbeat',
      partnerName: partnerName,
      widgetLabel: 'Heartbeat',
      tipEmoji: '💗',
      enableMultiCount: true,
      onSendWithCount: (count) {
        Get.back();
        onSend(count);
      },
      onSend: () {
        Get.back();
        onSend(1);
      },
      hero: Assets.images.heartbeatImage.image(
        width: 120.w,
        height: 110.w,
        fit: BoxFit.contain,
      ),
    );
  }
}
