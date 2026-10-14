import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/handle_exceptions.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../global/widgets/global_snackbar.dart';

class EditProfileController extends GetxController {
  final IUserRepository _userRepository = Get.find<IUserRepository>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  /// Avatar currently saved on the server.
  String? _savedAvatarPath;

  /// Newly picked photo (not uploaded yet).
  final pickedBytes = Rxn<Uint8List>();
  final removeAvatar = false.obs;
  final isSaving = false.obs;

  String get email => SessionService.to.user?.email ?? '';

  /// Saved avatar to show when nothing new is picked.
  String? get displayAvatarPath => removeAvatar.value ? null : _savedAvatarPath;

  bool get hasAvatar =>
      pickedBytes.value != null || displayAvatarPath != null;

  @override
  void onInit() {
    super.onInit();
    final user = SessionService.to.user;
    nameController.text = user?.fullName ?? '';
    _savedAvatarPath = user?.avatarPath;
  }

  Future<void> pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 82,
      );
      if (file == null) return;
      pickedBytes.value = await file.readAsBytes();
      removeAvatar.value = false;
    } catch (e) {
      Log.w('EditProfile: pick failed: $e');
      globalSnackBar(
        title: 'Photo unavailable',
        message: source == ImageSource.camera
            ? 'Allow camera access in Settings to take a photo.'
            : 'Allow photo access in Settings to choose a photo.',
      );
    }
  }

  void clearAvatar() {
    pickedBytes.value = null;
    removeAvatar.value = true;
  }

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Name is required';
    if (name.length > 60) return 'Name must be 60 characters or less';
    return null;
  }

  Future<void> save() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isSaving.value = true;
    try {
      final oldPath = _savedAvatarPath;
      String? newAvatarPath;
      final bytes = pickedBytes.value;
      if (bytes != null) {
        newAvatarPath = await _userRepository.uploadAvatar(bytes);
      } else if (removeAvatar.value && oldPath != null) {
        newAvatarPath = '';
      }

      final session = await _userRepository.updateProfile(
        fullName: nameController.text.trim(),
        avatarPath: newAvatarPath,
      );
      SessionService.to.apply(session);

      if (newAvatarPath != null && oldPath != null) {
        _userRepository.deleteAvatarFile(oldPath).catchError((Object e) {
          Log.w('EditProfile: old avatar cleanup failed: $e');
        });
      }

      Get.back();
      globalSnackBar(title: 'Saved', message: 'Your profile has been updated.');
    } catch (e) {
      handleException(e, context: 'Update profile');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
