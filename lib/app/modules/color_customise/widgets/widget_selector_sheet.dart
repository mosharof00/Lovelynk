import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/app_widget_type.dart';
import '../../../data/models/widget_models/widget_definition.dart';
import '../../../data/widget_catalog/widget_catalog.dart';
import '../../../global/widgets/app_svg_icon.dart';

/// A tappable trigger row that opens the widget selector as a bottom sheet.
class WidgetSelectorField extends StatelessWidget {
  const WidgetSelectorField({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppWidgetType selected;
  final ValueChanged<AppWidgetType> onSelected;

  WidgetDefinition get _current =>
      WidgetCatalog.byType(selected) ?? WidgetCatalog.all.first;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColor.inputBorder),
        ),
        child: Row(
          children: [
            _IconBadge(icon: _current.icon),
            12.horizontalSpace,
            Expanded(
              child: Text(
                _current.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColor.hintText,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WidgetSelectorSheet(
        selected: selected,
        onSelected: (type) {
          Navigator.pop(context);
          onSelected(type);
        },
      ),
    );
  }
}

// ── Bottom sheet ─────────────────────────────────────────────────────────────

class _WidgetSelectorSheet extends StatelessWidget {
  const _WidgetSelectorSheet({
    required this.selected,
    required this.onSelected,
  });

  final AppWidgetType selected;
  final ValueChanged<AppWidgetType> onSelected;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // drag handle
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColor.inputBorder,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                child: Row(
                  children: [
                    Text(
                      'Select Widget',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22.sp,
                        color: AppColor.hintText,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColor.inputBorder),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  itemCount: WidgetCatalog.all.length,
                  separatorBuilder: (_, __) => SizedBox(height: 4.h),
                  itemBuilder: (context, index) {
                    final w = WidgetCatalog.all[index];
                    final isActive = w.type == selected;
                    return _WidgetTile(
                      item: w,
                      isActive: isActive,
                      onTap: () => onSelected(w.type),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
            ],
          ),
        );
      },
    );
  }
}

// ── Single row tile ───────────────────────────────────────────────────────────

class _WidgetTile extends StatefulWidget {
  const _WidgetTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final WidgetDefinition item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_WidgetTile> createState() => _WidgetTileState();
}

class _WidgetTileState extends State<_WidgetTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isActive || _pressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          // gradient: isSelected ? AppGradient.brand : null,
          color: isSelected ? AppColor.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            _IconBadge(
              icon: widget.item.icon,
              isSelected: isSelected,
            ),
            12.horizontalSpace,
            Expanded(
              child: Text(
                widget.item.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? AppColor.white : AppColor.textPrimary,
                ),
              ),
            ),
            if (widget.isActive)
              Icon(
                Icons.check_circle_rounded,
                size: 20.sp,
                color: AppColor.white,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Solid icon badge ──────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.isSelected = false});

  final String icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColor.white.withValues(alpha: 0.25)
            : AppColor.primaryLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        icon,
        size: 18.sp,
        color: isSelected ? AppColor.white : AppColor.primary,
      ),
    );
  }
}
