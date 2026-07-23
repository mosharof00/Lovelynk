import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:bulkretail/app/core/extensions/text_style_extension.dart';
import 'package:bulkretail/app/core/theme/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_text.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({
    super.key,
    required this.count,
    required this.icon,
    this.onTap,
  });

  final String count;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasBadge = count != '0';

    return InkWell(
      onTap: onTap,
      child: hasBadge
          ? badges.Badge(
        position: badges.BadgePosition.topEnd(top: -12, end: -10),
        badgeStyle: badges.BadgeStyle(
          badgeColor: AppColor.primary,
          padding: EdgeInsets.all(5.r),
          borderSide: BorderSide(color: Colors.white, width: 1.5.r),
        ),
        badgeContent: AppText(
          count,
          style: context.labelSmall.copyWith(color: Colors.white),
        ),
        badgeAnimation: const badges.BadgeAnimation.slide(
          animationDuration: Duration(seconds: 2),
          loopAnimation: false,
        ),
        child: icon,
      )
          : icon,
    );
  }
}