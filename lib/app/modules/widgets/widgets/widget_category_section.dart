import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../global/widgets/app_text.dart';
import 'renderers/love_widget_card.dart';
import 'renderers/widget_body_builder.dart';

class WidgetCategorySection extends StatelessWidget {
  const WidgetCategorySection({
    super.key,
    required this.category,
    required this.widgets,
    required this.isUnlocked,
    required this.onAdd,
    required this.onUnlock,
    required this.onSend,
    this.onSeeAll,
    this.showSeeAll = true,
  });

  final WidgetCategory category;
  final List<WidgetDefinition> widgets;
  final bool isUnlocked;
  final ValueChanged<WidgetDefinition> onAdd;
  final VoidCallback onUnlock;
  final ValueChanged<WidgetDefinition> onSend;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty) return const SizedBox.shrink();

    final wide = widgets.where((w) => w.isWide).toList();
    final normal = widgets.where((w) => !w.isWide).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                category.title,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            if (showSeeAll && onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: AppText(
                  'See all',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.secondary,
                  ),
                ),
              ),
          ],
        ),
        12.verticalSpace,
        for (final item in wide) ...[
          SizedBox(height: 150.h, child: _card(item)),
          12.verticalSpace,
        ],
        if (normal.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: normal.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) => _card(normal[index]),
          ),
      ],
    );
  }

  Widget _card(WidgetDefinition item) {
    return LoveWidgetCard(
      title: item.title,
      isUnlocked: isUnlocked,
      onAction: () => isUnlocked ? onAdd(item) : onUnlock(),
      onSend: item.isInteractive
          ? () => isUnlocked ? onSend(item) : onUnlock()
          : null,
      sendLabel: item.sendLabel,
      child: buildWidgetBody(item.type),
    );
  }
}
