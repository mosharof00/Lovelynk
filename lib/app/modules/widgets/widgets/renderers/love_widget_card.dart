import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../global/widgets/app_text.dart';

/// Shared shell for every widget card: title, live body, and footer action(s).
///
/// Interactive widgets pass [onSend] + [sendLabel] so the footer shows
/// "Add Widget | Send …" — the card body itself is not tappable.
///
/// Use [compact] on Home (narrow columns) for smaller type / shorter labels.
class LoveWidgetCard extends StatelessWidget {
  const LoveWidgetCard({
    super.key,
    required this.title,
    required this.child,
    required this.isUnlocked,
    required this.onAction,
    this.onSend,
    this.sendLabel,
    this.compact = false,
  });

  final String title;
  final Widget child;
  final bool isUnlocked;
  final VoidCallback onAction;
  final VoidCallback? onSend;
  final String? sendLabel;
  final bool compact;

  bool get _showSend =>
      isUnlocked && onSend != null && (sendLabel?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 11.sp : 13.sp;
    final padH = compact ? 6.w : 10.w;
    final padTop = compact ? 8.h : 12.h;
    final padBottom = compact ? 6.h : 8.h;
    final gapAfterTitle = compact ? 4.h : 10.h;
    final gapBeforeDivider = compact ? 4.h : 8.h;

    final addLabel = compact
        ? (isUnlocked ? 'Add' : 'Unlock')
        : (isUnlocked ? 'Add Widget' : 'Unlock Widget');
    final sendText = compact ? 'Send' : (sendLabel ?? 'Send');

    return Container(
      padding: EdgeInsets.fromLTRB(padH, padTop, padH, padBottom),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(compact ? 14.r : 20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: compact ? 8 : 14,
            offset: const Offset(0, 3),
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
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
              if (!isUnlocked)
                Icon(
                  Icons.lock_rounded,
                  size: compact ? 11.sp : 14.sp,
                  color: AppColor.hintText,
                ),
            ],
          ),
          SizedBox(height: gapAfterTitle),
          Expanded(
            child: compact ? child : Center(child: child),
          ),
          SizedBox(height: gapBeforeDivider),
          Divider(
            height: 1,
            thickness: 0.6,
            color: AppColor.inputBorder.withValues(alpha: 0.8),
          ),
          SizedBox(height: compact ? 4.h : 6.h),
          if (_showSend)
            Row(
              children: [
                Expanded(
                  child: _FooterAction(
                    label: addLabel,
                    icon: Icons.add_rounded,
                    onTap: onAction,
                    compact: compact,
                  ),
                ),
                Container(
                  width: 1,
                  height: compact ? 12.h : 16.h,
                  color: AppColor.inputBorder.withValues(alpha: 0.9),
                ),
                Expanded(
                  child: _FooterAction(
                    label: sendText,
                    icon: Icons.send_outlined,
                    onTap: onSend!,
                    compact: compact,
                  ),
                ),
              ],
            )
          else
            _FooterAction(
              label: addLabel,
              icon: isUnlocked ? Icons.add_rounded : Icons.lock_open_rounded,
              onTap: onAction,
              compact: compact,
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
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: compact ? 10.sp : 12.sp,
              color: AppColor.secondary,
            ),
            SizedBox(width: compact ? 2.w : 3.w),
            Flexible(
              child: AppText(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: compact ? 9.sp : 11.sp,
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
