import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';

/// Shared shell for every widget card: title, live body, and footer action.
///
/// The body ([child]) is the widget's real look; this shell only owns the
/// frame, the title row (with lock state) and the single footer button so all
/// 12 widgets stay visually consistent.
///
/// Interactive widgets pass [onTap] so tapping anywhere on the card fires the
/// action (e.g. send a kiss); the footer stays as "Add Widget".
class LoveWidgetCard extends StatelessWidget {
  const LoveWidgetCard({
    super.key,
    required this.title,
    required this.child,
    required this.isUnlocked,
    required this.onAction,
    this.onTap,
  });

  final String title;
  final Widget child;
  final bool isUnlocked;

  /// Footer: Add Widget / Unlock Widget.
  final VoidCallback onAction;

  /// Whole-card tap (interactive widgets only).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  title,
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
          10.verticalSpace,
          Expanded(child: Center(child: child)),
          8.verticalSpace,
          Divider(
            height: 1,
            thickness: 0.6,
            color: AppColor.inputBorder.withValues(alpha: 0.8),
          ),
          6.verticalSpace,
          _FooterAction(
            label: isUnlocked ? 'Add Widget' : 'Unlock Widget',
            icon: isUnlocked ? Icons.add_rounded : Icons.lock_open_rounded,
            onTap: onAction,
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14.sp, color: AppColor.secondary),
          4.horizontalSpace,
          Flexible(
            child: AppText(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
