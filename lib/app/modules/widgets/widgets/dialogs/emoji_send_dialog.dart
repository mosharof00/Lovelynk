import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_color.dart';
import 'interactive_send_dialog.dart';

/// Emoji send dialog — same shell as Kiss/Heartbeat, with a picker under the hero.
class EmojiSendDialog {
  EmojiSendDialog._();

  static const emojis = ['😍', '😘', '🥰', '😂', '😊', '😭', '🔥', '👍', '🎉'];

  static Future<void> show({
    required String partnerName,
    required ValueChanged<String> onSend,
    required VoidCallback onViewDetails,
  }) {
    final selected = emojis.first.obs;

    return InteractiveSendDialog.show(
      title: 'Send an Emoji',
      message: 'Pick an emoji to send to $partnerName 💞',
      sendLabel: 'Send Emoji',
      partnerName: partnerName,
      widgetLabel: 'Emoji',
      tipEmoji: '😍',
      onSend: () {
        final emoji = selected.value;
        Get.back();
        onSend(emoji);
      },
      onViewDetails: () {
        Get.back();
        onViewDetails();
      },
      hero: Obx(
        () => Text(
          selected.value,
          style: TextStyle(fontSize: 72.sp, height: 1),
        ),
      ),
      belowHero: Obx(
        () => Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            for (final emoji in emojis)
              GestureDetector(
                onTap: () => selected.value = emoji,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected.value == emoji
                        ? AppColor.primaryLight
                        : AppColor.inputFill,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selected.value == emoji
                          ? AppColor.primary
                          : AppColor.inputBorder,
                      width: selected.value == emoji ? 1.5 : 1,
                    ),
                  ),
                  child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
