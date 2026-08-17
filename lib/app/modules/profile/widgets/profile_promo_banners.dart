import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/glass_card.dart';

class ProfilePromoBanners extends StatelessWidget {
  const ProfilePromoBanners({
    super.key,
    required this.onReferTap,
    required this.onRateTap,
  });

  final VoidCallback onReferTap;
  final VoidCallback onRateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _PromoBanner(
        //   onTap: onReferTap,
        //   accentColor: AppColor.primary,
        //   leadingIcon: AppSvgIcon(
        //     Assets.icons.loveIcon,
        //     size: 22.sp,
        //     color: AppColor.primary,
        //   ),
        //   title: 'Refer a couple, get 1 month free',
        //   subtitle: 'Share lovelynk and get rewarded.',
        //   trailing: Icon(
        //     Icons.card_giftcard_rounded,
        //     size: 32.sp,
        //     color: AppColor.primary,
        //   ),
        // ),
        12.verticalSpace,
        _PromoBanner(
          onTap: onRateTap,
          accentColor: AppColor.secondary,
          leadingIcon: Icon(
            Icons.star_rounded,
            size: 22.sp,
            color: AppColor.secondary,
          ),
          title: 'Rate us 5-stars',
          subtitle: 'Love using lovelynk? Rate us on the App Store.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (_) => Icon(
                Icons.star_rounded,
                size: 14.sp,
                color: AppColor.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.onTap,
    required this.accentColor,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final VoidCallback onTap;
  final Color accentColor;
  final Widget leadingIcon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      borderRadius: BorderRadius.circular(16.r),
      child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: leadingIcon,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                      ),
                      maxLines: 2,
                    ),
                    4.verticalSpace,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.textSecondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              8.horizontalSpace,
              trailing,
            ],
          ),
    );
  }
}
