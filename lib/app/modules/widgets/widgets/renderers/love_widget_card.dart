import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';

/// Shared shell for every widget card: title, live body, and footer action(s).
///
/// Interactive widgets pass [onSend] + [sendLabel] so the footer shows
/// "Add Widget | Send …" — the card body itself is not tappable.
class LoveWidgetCard extends StatelessWidget {
  const LoveWidgetCard({
    super.key,
    required this.title,
    required this.child,
    required this.isUnlocked,
    required this.onAction,
    this.onSend,
    this.sendLabel,
  });

  final String title;
  final Widget child;
  final bool isUnlocked;

  /// Footer: Add Widget / Unlock Widget.
  final VoidCallback onAction;

  /// Optional second footer action (interactive widgets only).
  final VoidCallback? onSend;
  final String? sendLabel;

  bool get _showSend =>
      isUnlocked && onSend != null && (sendLabel?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 8.h),
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
          if (_showSend)
            Row(
              children: [
                Expanded(
                  child: _FooterAction(
                    label: 'Add Widget',
                    icon: Icons.add_rounded,
                    onTap: onAction,
                  ),
                ),
                Container(
                  width: 1,
                  height: 16.h,
                  color: AppColor.inputBorder.withValues(alpha: 0.9),
                ),
                Expanded(
                  child: _FooterAction(
                    label: sendLabel!,
                    icon: Icons.send_outlined,
                    onTap: onSend!,
                  ),
                ),
              ],
            )
          else
            _FooterAction(
              label: isUnlocked ? 'Add Widget' : 'Unlock Widget',
              icon: isUnlocked ? Icons.add_rounded : Icons.lock_open_rounded,
              onTap: onAction,
            ),
        ],
      ),
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
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 2.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10.sp, color: AppColor.secondary),
            3.horizontalSpace,
            Flexible(
              child: AppText(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
