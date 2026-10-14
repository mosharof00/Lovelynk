import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/extensions/text_style_extension.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../global/widgets/app_input_text_form_field.dart';
import '../../../global/widgets/app_text.dart';
import '../../../global/widgets/custom_appbar.dart';
import '../../../global/widgets/global_button.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: CustomAppBar(
        title: 'Contact Us',
        showBackButton: true,
        backgroundColor: AppColor.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  'Tell us what’s going on and we’ll reply to your account email.',
                  maxLines: 3,
                  style: context.bodyMedium.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
                20.verticalSpace,
                _Label('Topic'),
                8.verticalSpace,
                Obx(
                  () => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final c in SupportCategory.values)
                        ChoiceChip(
                          label: Text(ContactUsController.categoryLabel(c)),
                          selected: controller.category.value == c,
                          onSelected: (_) => controller.category.value = c,
                          selectedColor: AppColor.primaryLight,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: controller.category.value == c
                                ? AppColor.primary
                                : AppColor.textSecondary,
                          ),
                          side: BorderSide(
                            color: controller.category.value == c
                                ? AppColor.primary
                                : AppColor.inputBorder,
                          ),
                        ),
                    ],
                  ),
                ),
                18.verticalSpace,
                AppInputTextFormField(
                  label: 'Subject',
                  controller: controller.subjectController,
                  hintText: 'Short summary',
                  maxLength: 120,
                  validator: controller.validateSubject,
                ),
                14.verticalSpace,
                AppInputTextFormField(
                  label: 'Message',
                  controller: controller.messageController,
                  hintText: 'Describe the issue or idea…',
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  maxLength: 4000,
                  validator: controller.validateMessage,
                ),
                14.verticalSpace,
                _Label('Screenshots (optional)'),
                8.verticalSpace,
                Obx(
                  () => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      for (final file in controller.attachments)
                        _AttachmentThumb(
                          path: file.path,
                          onRemove: () => controller.removeAttachment(file),
                        ),
                      if (controller.attachments.length <
                          ContactUsController.maxAttachments)
                        _AddAttachmentTile(onTap: controller.addAttachment),
                    ],
                  ),
                ),
                28.verticalSpace,
                Obx(
                  () => GlobalButton(
                    text: 'Send',
                    onTap: controller.submit,
                    isLoading: controller.isSending.value,
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.textPrimary,
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final size = 76.w;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(path),
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6.w,
          right: -6.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: AppColor.textPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 14.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddAttachmentTile extends StatelessWidget {
  const _AddAttachmentTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 76.w;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.inputBorder),
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: AppColor.hintText,
          size: 26.sp,
        ),
      ),
    );
  }
}
