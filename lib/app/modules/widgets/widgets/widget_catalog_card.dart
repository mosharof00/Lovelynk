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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.inputBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppText(
                  widget.title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              if (!isUnlocked)
                Icon(Icons.lock_rounded, size: 14.sp, color: AppColor.hintText),
            ],
          ),
          6.verticalSpace,
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColor.primaryLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(widget.icon, size: 16.sp, color: AppColor.primary),
          ),
          8.verticalSpace,
          AppText(
            widget.previewValue,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
          AppText(
            widget.previewUnit,
            maxLines: 1,
            style: TextStyle(fontSize: 11.sp, color: AppColor.textSecondary),
          ),
          6.verticalSpace,

          Container(
            width: double.infinity,
            height: 0.5.h,
            color: Colors.grey.shade300,
          ),
          2.verticalSpace,
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    isUnlocked ? 'Add' : 'Unlock',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.sp,
                  color: AppColor.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
