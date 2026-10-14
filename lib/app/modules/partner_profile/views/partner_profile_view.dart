import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../../../global/widgets/initials_avatar.dart';
import '../controllers/partner_profile_controller.dart';

class PartnerProfileView extends GetView<PartnerProfileController> {
  const PartnerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Partner Profile',
        showBackButton: true,
        backgroundColor: AppColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
            children: [
              Center(
                child: InitialsAvatar(
                  name: controller.fullName.value,
                  avatarPath: controller.avatarPath.value,
                  size: 112.w,
                ),
              ),
              16.verticalSpace,
              AppText(
                controller.name.value,
                textAlign: TextAlign.center,
                style: context.headlineLarge.copyWith(
                  color: AppColor.textPrimary,
                ),
              ),
              if (controller.nickname.value != null) ...[
                4.verticalSpace,
                AppText(
                  controller.fullName.value,
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
              28.verticalSpace,
              _InfoCard(
                rows: [
                  _InfoRow(
                    icon: Icons.edit_outlined,
                    label: 'Your nickname for them',
                    value: controller.nickname.value ?? 'Add',
                    onTap: controller.editNickname,
                  ),
                  _InfoRow(
                    icon: Icons.favorite_border_rounded,
                    label: 'Together since',
                    value: controller.togetherSince.value ?? 'Set date',
                    onTap: () => controller.editAnniversary(context),
                  ),
                  if (controller.daysTogether.value != null)
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Days together',
                      value: '${controller.daysTogether.value}',
                    ),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Their local time',
                    value: controller.localTime.value ?? '--',
                  ),
                  if (controller.city.value != null)
                    _InfoRow(
                      icon: Icons.public_rounded,
                      label: 'Time zone',
                      value: controller.city.value!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            InkWell(
              onTap: rows[i].onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColor.primaryLight.withAlpha(150),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        rows[i].icon,
                        size: 18.sp,
                        color: AppColor.primary,
                      ),
                    ),
                    14.horizontalSpace,
                    Expanded(
                      child: AppText(
                        rows[i].label,
                        style: context.bodyLarge.copyWith(
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    AppText(
                      rows[i].value,
                      style: context.bodyMedium.copyWith(
                        color:
                            rows[i].onTap != null &&
                                (rows[i].value == 'Add' ||
                                    rows[i].value == 'Set date')
                            ? AppColor.primary
                            : AppColor.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                    if (rows[i].onTap != null) ...[
                      4.horizontalSpace,
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20.sp,
                        color: AppColor.hintText,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (i != rows.length - 1)
              Divider(
                height: 1,
                thickness: 0.8,
                indent: 66.w,
                color: AppColor.inputBorder,
              ),
          ],
        ],
      ),
    );
  }
}
