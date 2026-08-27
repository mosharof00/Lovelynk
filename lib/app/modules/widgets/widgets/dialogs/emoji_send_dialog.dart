import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_color.dart';
import 'interactive_send_dialog.dart';

/// Emoji send dialog — same shell as Kiss/Heartbeat, with a full picker.
class EmojiSendDialog {
  EmojiSendDialog._();

  static Future<void> show({
    required String partnerName,
    required ValueChanged<String> onSend,
    required VoidCallback onViewDetails,
  }) {
    final selected = '😍'.obs;

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
      belowHero: _EmojiPickerPanel(
        onSelected: (emoji) => selected.value = emoji,
      ),
    );
  }
}

class _EmojiPickerPanel extends StatelessWidget {
  const _EmojiPickerPanel({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isIos = foundation.defaultTargetPlatform == TargetPlatform.iOS;
    final surface = Colors.white.withValues(alpha: 0.72);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: EmojiPicker(
        onEmojiSelected: (_, emoji) => onSelected(emoji.emoji),
        config: Config(
          height: 220.h,
          checkPlatformCompatibility: true,
          viewOrderConfig: const ViewOrderConfig(
            top: EmojiPickerItem.categoryBar,
            middle: EmojiPickerItem.emojiView,
            bottom: EmojiPickerItem.searchBar,
          ),
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28 * (isIos ? 1.2 : 1.0),
            backgroundColor: surface,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: true,
            noRecents: const Text(
              'No recents yet',
              style: TextStyle(fontSize: 16, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
          ),
          categoryViewConfig: CategoryViewConfig(
            initCategory: Category.SMILEYS,
            recentTabBehavior: RecentTabBehavior.RECENT,
            backgroundColor: surface,
            indicatorColor: AppColor.primary,
            iconColor: AppColor.hintText,
            iconColorSelected: AppColor.primary,
            backspaceColor: AppColor.primary,
            dividerColor: Colors.white.withValues(alpha: 0.4),
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            showBackspaceButton: false,
            showSearchViewButton: true,
            backgroundColor: AppColor.primary,
            buttonColor: AppColor.primary,
            buttonIconColor: Colors.white,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: surface,
            buttonIconColor: AppColor.primary,
            hintText: 'Search emoji',
          ),
          skinToneConfig: const SkinToneConfig(
            enabled: true,
            indicatorColor: AppColor.primary,
            rememberSkinTone: true,
          ),
        ),
      ),
    );
  }
}
