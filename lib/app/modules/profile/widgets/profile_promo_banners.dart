import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/app_text.dart';

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
        _PromoBanner(
          onTap: onReferTap,
          background: const Color(0xFFFFE8F2),
          leading: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColor.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppSvgIcon(
              Assets.icons.loveIcon,
              size: 22.sp,
              color: AppColor.primary,
            ),
          ),
          title: 'Refer a couple, get 1 month free',
          subtitle: 'Share lovelynk and get rewarded.',
          trailing: Icon(
            Icons.card_giftcard_rounded,
            size: 36.sp,
            color: AppColor.primary,
          ),
        ),
        12.verticalSpace,
        _PromoBanner(
          onTap: onRateTap,
          background: const Color(0xFFE8F4FF),
          leading: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColor.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.star_rounded,
              size: 24.sp,
              color: AppColor.secondary,
            ),
          ),
          title: 'Rate us 5-stars',
          subtitle: 'Love using lovelynk? Rate us on the App Store.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (_) => Icon(
                Icons.star_rounded,
                size: 16.sp,
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
    required this.background,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final VoidCallback onTap;
  final Color background;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Row(
            children: [
              leading,
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      style: context.titleSmall.copyWith(
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                      maxLines: 2,
                    ),
                    4.verticalSpace,
                    AppText(
                      subtitle,
                      style: context.bodySmall.copyWith(
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
        ),
      ),
    );
  }
}
