import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/widget_style.dart';
import '../../../global/widgets/app_text.dart';

class FontAndSizeSelectors extends StatelessWidget {
  const FontAndSizeSelectors({
    super.key,
    required this.font,
    required this.textSize,
    required this.onFontChanged,
    required this.onSizeChanged,
  });

  final WidgetSystemFont font;
  final WidgetTextSize textSize;
  final ValueChanged<WidgetSystemFont> onFontChanged;
  final ValueChanged<WidgetTextSize> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Font',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        8.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<WidgetSystemFont>(
              value: font,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColor.hintText),
              items: [
                for (final f in WidgetSystemFont.values)
                  DropdownMenuItem(
                    value: f,
                    child: AppText(
                      f.label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColor.textPrimary,
                        fontFamily: f.fontFamily,
                      ),
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onFontChanged(v);
              },
            ),
          ),
        ),
        16.verticalSpace,
        AppText(
          'Text Style',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        8.verticalSpace,
        Row(
          children: [
            for (final size in WidgetTextSize.values) ...[
              if (size != WidgetTextSize.values.first) 8.horizontalSpace,
              Expanded(
                child: GestureDetector(
                  onTap: () => onSizeChanged(size),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: textSize == size ? AppColor.primaryLight : AppColor.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: textSize == size
                            ? AppColor.primary
                            : AppColor.inputBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        AppText(
                          'Aa',
                          style: TextStyle(
                            fontSize: size == WidgetTextSize.small
                                ? 14.sp
                                : size == WidgetTextSize.medium
                                    ? 18.sp
                                    : 22.sp,
                            fontWeight: FontWeight.w600,
                            color: textSize == size
                                ? AppColor.primary
                                : AppColor.textPrimary,
                          ),
                        ),
                        2.verticalSpace,
                        AppText(
                          size.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textSize == size
                                ? AppColor.primary
                                : AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
