import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_scaffold.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/color_customise_controller.dart';
import '../widgets/background_toggle_section.dart';
import '../widgets/colour_theme_picker.dart';
import '../widgets/customise_lock_preview.dart';
import '../widgets/font_and_size_selectors.dart';
import '../widgets/widget_selector_sheet.dart';

class ColorCustomiseView extends GetView<ColorCustomiseController> {
  const ColorCustomiseView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Obx(() {
        final style = controller.style.value;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Customise',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            AppText(
                              'Make every widget uniquely yours',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: controller.resetToDefault,
                        child: AppText(
                          'Reset to Default',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  5.verticalSpace,
                  Center(
                    child: CustomiseLockPreview(
                      widget: controller.selectedWidget,
                      style: style,
                      themeColor: controller.themeColor,
                      backgroundColor: controller.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Select Widget',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    8.verticalSpace,
                    WidgetSelectorField(
                      selected: controller.selectedType.value,
                      onSelected: controller.selectWidget,
                    ),
                    4.verticalSpace,
                    AppText(
                      controller.selectedWidget.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.hintText,
                      ),
                    ),
                    20.verticalSpace,
                    ColourThemePicker(
                      selectedId: style.themeColorId,
                      onSelected: controller.setThemeColor,
                    ),
                    20.verticalSpace,
                    BackgroundToggleSection(
                      useBackground: style.useBackground,
                      selectedColorId: style.backgroundColorId,
                      onToggle: controller.setUseBackground,
                      onColorSelected: controller.setBackgroundColor,
                    ),
                    20.verticalSpace,
                    FontAndSizeSelectors(
                      font: style.font,
                      textSize: style.textSize,
                      onFontChanged: controller.setFont,
                      onSizeChanged: controller.setTextSize,
                    ),
                    28.verticalSpace,
                    GlobalButton(
                      onTap: controller.isSaving.value
                          ? () {}
                          : controller.saveChanges,
                      text: controller.isSaving.value
                          ? 'Saving...'
                          : 'Save Changes',
                      isDisabled: controller.isSaving.value,
                      suffixWidget: Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
