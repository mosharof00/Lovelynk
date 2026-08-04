import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/widget_style.dart';
import '../../../global/widgets/app_color_picker.dart';
import '../../../global/widgets/app_text.dart';

class BackgroundToggleSection extends StatelessWidget {
  const BackgroundToggleSection({
    super.key,
    required this.useBackground,
    required this.selectedColorId,
    required this.onToggle,
    required this.onColorSelected,
  });

  final bool useBackground;
  final String selectedColorId;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onColorSelected;

  bool get _isCustomSelected =>
      WidgetStyleOptions.isCustomId(selectedColorId);

  Color get _customColor =>
      WidgetStyleOptions.byId(selectedColorId).color;

  Future<void> _openCustomPicker(BuildContext context) async {
    final picked = await showAppColorPicker(
      context: context,
      initialColor: WidgetStyleOptions.byId(selectedColorId).color,
      title: 'Background colour',
    );
    if (picked == null) return;
    onColorSelected(WidgetStyleOptions.colorToCustomId(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Background',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        10.verticalSpace,
        Row(
          children: [
            _ChoiceChip(
              label: 'No',
              selected: !useBackground,
              onTap: () => onToggle(false),
            ),
            10.horizontalSpace,
            _ChoiceChip(
              label: 'Yes',
              selected: useBackground,
              onTap: () => onToggle(true),
            ),
          ],
        ),
        if (useBackground) ...[
          12.verticalSpace,
          AppText(
            'Background colour',
            style: TextStyle(fontSize: 12.sp, color: AppColor.textSecondary),
          ),
          8.verticalSpace,
          Wrap(
            spacing: 12.w,
            runSpacing: 10.h,
            children: [
              for (final c in WidgetStyleOptions.themeColors)
                GestureDetector(
                  onTap: () => onColorSelected(c.id),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedColorId == c.id
                            ? AppColor.textPrimary
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              CustomColorSwatchButton(
                size: 32.w,
                showLabel: false,
                isSelected: _isCustomSelected,
                customColor: _isCustomSelected ? _customColor : null,
                onTap: () => _openCustomPicker(context),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : AppColor.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColor.primary : AppColor.inputBorder,
          ),
        ),
        child: AppText(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}
