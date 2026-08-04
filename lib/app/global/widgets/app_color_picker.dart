import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_gradient.dart';

/// Opens a polished [ColorPicker] dialog and returns the chosen color,
/// or `null` if the user cancels.
Future<Color?> showAppColorPicker({
  required BuildContext context,
  required Color initialColor,
  String title = 'Pick a colour',
}) async {
  var selected = initialColor;

  final confirmed = await ColorPicker(
    color: initialColor,
    onColorChanged: (color) => selected = color,
    heading: Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      ),
    ),
    subheading: Text(
      'Select shade',
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColor.textSecondary,
      ),
    ),
    wheelSubheading: Text(
      'Selected colour and shade',
      style: TextStyle(
        fontSize: 12.sp,
        color: AppColor.textSecondary,
      ),
    ),
    showMaterialName: false,
    showColorName: true,
    showColorCode: true,
    enableShadesSelection: true,
    pickersEnabled: const <ColorPickerType, bool>{
      ColorPickerType.both: false,
      ColorPickerType.primary: true,
      ColorPickerType.accent: false,
      ColorPickerType.bw: false,
      ColorPickerType.custom: false,
      ColorPickerType.wheel: true,
    },
    width: 40,
    height: 40,
    borderRadius: 20,
    spacing: 8,
    runSpacing: 8,
    wheelDiameter: 190,
    materialNameTextStyle: TextStyle(
      fontSize: 11.sp,
      color: AppColor.textSecondary,
    ),
    colorNameTextStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: AppColor.textPrimary,
    ),
    colorCodeTextStyle: TextStyle(
      fontSize: 12.sp,
      color: AppColor.textPrimary,
    ),
    pickerTypeTextStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: AppColor.textPrimary,
    ),
    actionButtons: const ColorPickerActionButtons(
      dialogActionButtons: true,
      dialogActionOrder: ColorPickerActionButtonOrder.okIsRight,
    ),
  ).showPickerDialog(
    context,
    backgroundColor: AppColor.white,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    constraints: BoxConstraints(
      minHeight: 480.h,
      minWidth: 300.w,
      maxWidth: 340.w,
    ),
  );

  if (confirmed != true) return null;
  return selected;
}

/// Circular swatch used to open the custom color picker.
class CustomColorSwatchButton extends StatelessWidget {
  const CustomColorSwatchButton({
    super.key,
    required this.onTap,
    this.customColor,
    this.isSelected = false,
    this.size,
    this.showLabel = true,
  });

  final VoidCallback onTap;
  final Color? customColor;
  final bool isSelected;
  final double? size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final swatchSize = size ?? 36.w;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: swatchSize,
            height: swatchSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: customColor == null ? AppGradient.brand : null,
              color: customColor,
              border: Border.all(
                color: isSelected ? AppColor.textPrimary : Colors.white,
                width: isSelected ? 2.5 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (customColor ?? AppColor.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              customColor == null
                  ? Icons.add_rounded
                  : (isSelected ? Icons.check_rounded : Icons.palette_outlined),
              size: swatchSize * 0.45,
              color: customColor == null
                  ? Colors.white
                  : (customColor!.computeLuminance() > 0.55
                      ? AppColor.textPrimary
                      : Colors.white),
            ),
          ),
          if (showLabel) ...[
            4.verticalSpace,
            Text(
              'Custom',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
