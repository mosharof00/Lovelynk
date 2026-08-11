import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';

class ProfileMenuItemData {
  const ProfileMenuItemData({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.showStatusDot = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final bool showStatusDot;
  final VoidCallback? onTap;
}

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.titleColor,
    required this.items,
  });

  final String title;
  final Color titleColor;
  final List<ProfileMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _ProfileMenuTile(item: items[i]),
                if (i != items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    indent: 66.w,
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
  const _ProfileMenuTile({required this.item});

  final ProfileMenuItemData item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16.r),
      splashColor: AppColor.primaryLight,
      highlightColor: AppColor.primaryLight.withValues(alpha: 0.5),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                item.icon,
                size: 18.sp,
                color: AppColor.primary,
              ),
            ),
            14.horizontalSpace,
            Expanded(
              child: AppText(
                item.label,
                style: context.bodyLarge.copyWith(
                  color: AppColor.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (item.value != null) ...[
              AppText(
                item.value!,
                style: context.bodyMedium.copyWith(
                  color: item.valueColor ?? AppColor.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
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
              size: 20.sp,
              color: AppColor.hintText,
            ),
          ],
        ),
      ),
    );
  }
}
