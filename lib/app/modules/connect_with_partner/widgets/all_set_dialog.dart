import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/global_button.dart';

class AllSetDialog extends StatelessWidget {
  const AllSetDialog({
    super.key,
    required this.onLetsGo,
  });

  final VoidCallback onLetsGo;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 88.sp,
                  color: AppColor.primary,
                ),
                Icon(
                  Icons.check_rounded,
                  color: AppColor.white,
                  size: 36.sp,
                ),
              ],
            ),
            8.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 18.sp,
                  color: AppColor.primaryLight,
                ),
                10.horizontalSpace,
                AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 14.sp,
                  color: AppColor.secondary,
                ),
                10.horizontalSpace,
                AppSvgIcon(
                  Assets.icons.loveIcon,
                  size: 18.sp,
                  color: AppColor.primary.withValues(alpha: 0.45),
                ),
              ],
            ),
            20.verticalSpace,
            AppText(
              'All set! 💞',
              style: context.headlineMedium.copyWith(
                color: AppColor.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            AppText(
              "You're ready to stay connected with Lovelynk.",
              style: context.bodyMedium.copyWith(
                color: AppColor.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            28.verticalSpace,
            GlobalButton(
              text: "Let's Go",
              onTap: onLetsGo,
            ),
          ],
        ),
      ),
    );
  }
}
