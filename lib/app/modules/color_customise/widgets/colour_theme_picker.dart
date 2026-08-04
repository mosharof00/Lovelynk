import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/widget_style.dart';
import '../../../global/widgets/app_color_picker.dart';
import '../../../global/widgets/app_text.dart';

class ColourThemePicker extends StatelessWidget {
  const ColourThemePicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  bool get _isCustomSelected => WidgetStyleOptions.isCustomId(selectedId);

  Color get _customColor =>
      WidgetStyleOptions.byId(selectedId).color;

  Future<void> _openCustomPicker(BuildContext context) async {
    final picked = await showAppColorPicker(
      context: context,
      initialColor: _isCustomSelected
          ? _customColor
          : WidgetStyleOptions.byId(selectedId).color,
      title: 'Colour Theme',
    );
    if (picked == null) return;
    onSelected(WidgetStyleOptions.colorToCustomId(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Colour Theme',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        10.verticalSpace,
        Wrap(
          spacing: 12.w,
          runSpacing: 10.h,
          children: [
            for (final c in WidgetStyleOptions.themeColors)
              GestureDetector(
                onTap: () => onSelected(c.id),
                child: Column(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: c.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedId == c.id
                              ? AppColor.textPrimary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: c.color.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: selectedId == c.id
                          ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                          : null,
                    ),
                    4.verticalSpace,
                    AppText(
                      c.label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            CustomColorSwatchButton(
              isSelected: _isCustomSelected,
              customColor: _isCustomSelected ? _customColor : null,
              onTap: () => _openCustomPicker(context),
            ),
          ],
        ),
      ],
    );
  }
}
