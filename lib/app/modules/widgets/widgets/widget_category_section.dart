import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../global/widgets/app_text.dart';
import 'widget_catalog_card.dart';

class WidgetCategorySection extends StatelessWidget {
  const WidgetCategorySection({
    super.key,
    required this.category,
    required this.widgets,
    required this.isUnlocked,
    required this.onAdd,
    required this.onUnlock,
  });

  final WidgetCategory category;
  final List<WidgetDefinition> widgets;
  final bool isUnlocked;
  final ValueChanged<WidgetDefinition> onAdd;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          category.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textPrimary,
          ),
        ),
        12.verticalSpace,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widgets.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final item = widgets[index];
            return WidgetCatalogCard(
              widget: item,
              isUnlocked: isUnlocked,
              onAction: () => isUnlocked ? onAdd(item) : onUnlock(),
            );
          },
        ),
      ],
    );
  }
}
