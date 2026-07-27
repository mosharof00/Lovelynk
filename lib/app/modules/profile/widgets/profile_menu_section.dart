import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';

class ProfileMenuItemData {
  const ProfileMenuItemData({
    required this.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.showStatusDot = false,
  });

  final String key;
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final bool showStatusDot;
}

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.titleColor,
    required this.items,
    required this.onItemTap,
  });

  final String title;
  final Color titleColor;
  final List<ProfileMenuItemData> items;
  final void Function(String key) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: AppText(
            title,
            style: context.titleSmall.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColor.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _ProfileMenuTile(
                  item: items[i],
                  onTap: () => onItemTap(items[i].key),
                ),
                if (i != items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    indent: 52.w,
                    color: AppColor.inputBorder.withValues(alpha: 0.7),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.item,
    required this.onTap,
  });

  final ProfileMenuItemData item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 22.sp,
              color: AppColor.textPrimary.withValues(alpha: 0.75),
            ),
            14.horizontalSpace,
            Expanded(
              child: AppText(
                item.label,
                style: context.bodyLarge.copyWith(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
              ),
            ),
            if (item.value != null) ...[
              AppText(
                item.value!,
                style: context.bodyMedium.copyWith(
                  color: item.valueColor ?? AppColor.hintText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (item.showStatusDot) ...[
                6.horizontalSpace,
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColor.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              6.horizontalSpace,
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColor.hintText,
            ),
          ],
        ),
      ),
    );
  }
}
