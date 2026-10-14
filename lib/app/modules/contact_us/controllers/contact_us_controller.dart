import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/network/handle_exceptions.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../global/widgets/global_snackbar.dart';

class ContactUsController extends GetxController {
  final IUserRepository _userRepository = Get.find<IUserRepository>();

  static const maxAttachments = 3;

  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  final category = SupportCategory.general.obs;
  final attachments = <XFile>[].obs;
  final isSending = false.obs;

  static String categoryLabel(SupportCategory c) => switch (c) {
        SupportCategory.general => 'General',
        SupportCategory.bug => 'Bug report',
        SupportCategory.billing => 'Billing',
        SupportCategory.account => 'Account',
        SupportCategory.feedback => 'Feedback',
      };

  Future<void> addAttachment() async {
    if (attachments.length >= maxAttachments) return;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (file != null) attachments.add(file);
    } catch (e) {
      Log.w('ContactUs: pick failed: $e');
      globalSnackBar(
        title: 'Photo unavailable',
        message: 'Allow photo access in Settings to attach screenshots.',
      );
    }
  }

  void removeAttachment(XFile file) => attachments.remove(file);

  String? validateSubject(String? v) {
    final s = v?.trim() ?? '';
    if (s.length < 3) return 'Please add a short subject';
    if (s.length > 120) return 'Subject must be 120 characters or less';
    return null;
  }

  String? validateMessage(String? v) {
    final s = v?.trim() ?? '';
    if (s.length < 10) return 'Please describe the issue (at least 10 characters)';
    if (s.length > 4000) return 'Message is too long';
    return null;
  }

  Future<void> submit() async {
    if (isSending.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isSending.value = true;
    try {
      final paths = <String>[];
      for (final file in attachments) {
        final ext = file.path.split('.').last.toLowerCase();
        paths.add(await _userRepository.uploadSupportAttachment(
          await file.readAsBytes(),
          extension: const ['png', 'webp'].contains(ext) ? ext : 'jpg',
        ));
      }

      final info = await PackageInfo.fromPlatform();
      String? deviceModel;
      String? osVersion;
      if (Platform.isIOS) {
        final ios = await DeviceInfoPlugin().iosInfo;
        deviceModel = ios.utsname.machine;
        osVersion = 'iOS ${ios.systemVersion}';
      }

      await _userRepository.submitSupportTicket(
        category: category.value,
        subject: subjectController.text,
        message: messageController.text,
        attachmentPaths: paths,
        appVersion: '${info.version}+${info.buildNumber}',
        deviceModel: deviceModel,
        osVersion: osVersion,
      );

      Get.back();
      globalSnackBar(
        title: 'Message sent',
        message: 'Thanks! Our team will reply to your email soon.',
      );
    } catch (e) {
      isSending.value = false;
      handleException(e, context: 'Contact support');
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
