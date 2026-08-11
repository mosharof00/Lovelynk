import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../global/widgets/app_text.dart';

class WidgetCatalogCard extends StatelessWidget {
  const WidgetCatalogCard({
    super.key,
    required this.widget,
    required this.isUnlocked,
    required this.onAction,
  });

  final WidgetDefinition widget;
  final bool isUnlocked;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  widget.title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              if (!isUnlocked)
                Icon(Icons.lock_rounded, size: 14.sp, color: AppColor.hintText),
            ],
          ),
          const Spacer(),
          Icon(widget.icon, size: 28.sp, color: AppColor.primary),
          8.verticalSpace,
          AppText(
            widget.previewValue,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          if (widget.previewUnit.isNotEmpty) ...[
            2.verticalSpace,
            AppText(
              widget.previewUnit,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.primary,
              ),
            ),
          ],
          const Spacer(),
          Divider(
            height: 1,
            thickness: 0.6,
            color: AppColor.inputBorder.withValues(alpha: 0.8),
          ),
          8.verticalSpace,
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    isUnlocked ? 'Add Widget' : 'Unlock',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.secondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.sp,
                  color: AppColor.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
