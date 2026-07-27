import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../gen/assets.gen.dart';
import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_svg_icon.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/cached_image.dart';
import '../controllers/profile_controller.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: controller.onProfileTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              _Avatar(url: controller.avatarUrl.value),
              14.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            controller.userName.value,
                            style: context.headlineMedium.copyWith(
                              color: AppColor.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        if (controller.isPremium.value) ...[
                          6.horizontalSpace,
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 20.sp,
                            color: const Color(0xFFE8B923),
                          ),
                        ],
                      ],
                    ),
                    if (controller.isPremium.value) ...[
                      2.verticalSpace,
                      AppText(
                        'Premium',
                        style: context.bodySmall.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24.sp,
                color: AppColor.hintText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? CachedImage(
                imgUrl: url,
                width: 64.w,
                height: 64.w,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColor.primaryLight,
                alignment: Alignment.center,
                child: AppSvgIcon(
                  Assets.icons.profileFillIcon,
                  size: 28.sp,
                  color: AppColor.primary,
                ),
              ),
      ),
    );
  }
}
