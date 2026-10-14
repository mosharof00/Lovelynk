import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../../../global/widgets/global_button.dart';
import '../../../global/widgets/initials_avatar.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        showBackButton: true,
        backgroundColor: AppColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: _AvatarPicker(controller: controller)),
                32.verticalSpace,
                AppInputTextFormField(
                  label: 'Name',
                  controller: controller.nameController,
                  hintText: 'Your name',
                  maxLength: 60,
                  validator: controller.validateName,
                  autofillHints: const [AutofillHints.name],
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                ),
                14.verticalSpace,
                AppInputTextFormField(
                  label: 'Email',
                  initialValue: controller.email,
                  readOnly: true,
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: AppColor.hintText,
                    size: 20.sp,
                  ),
                ),
                28.verticalSpace,
                Obx(
                  () => GlobalButton(
                    text: 'Save',
                    onTap: controller.save,
                    isLoading: controller.isSaving.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.controller});

  final EditProfileController controller;

  void _showOptions(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetOption(
                icon: Icons.photo_camera_outlined,
                label: 'Take photo',
                onTap: () {
                  Get.back();
                  controller.pick(ImageSource.camera);
                },
              ),
              _SheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from library',
                onTap: () {
                  Get.back();
                  controller.pick(ImageSource.gallery);
                },
              ),
              if (controller.hasAvatar)
                _SheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove photo',
                  color: AppColor.error,
                  onTap: () {
                    Get.back();
                    controller.clearAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = 104.w;
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Obx(() {
            final bytes = controller.pickedBytes.value;
            if (bytes != null) {
              return ClipOval(
                child: Image.memory(
                  bytes,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
              );
            }
            return InitialsAvatar(
              name: controller.nameController.text,
              avatarPath: controller.displayAvatarPath,
              size: size,
            );
          }),
          Positioned(
            right: -2.w,
            bottom: -2.w,
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                size: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColor.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: tint, size: 22.sp),
      title: AppText(
        label,
        style: context.bodyLarge.copyWith(
          color: tint,
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
        ),
      ),
    );
  }
}
