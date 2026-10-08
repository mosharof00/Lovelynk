import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/handle_exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../global/widgets/global_snackbar.dart';
import '../../../../routes/app_pages.dart';
import '../../login/controllers/login_controller.dart';

/// Reached only after a verified recovery code, which signs the user in.
/// Leaving without saving signs that session out again.
///
/// Expects `Get.arguments = {'email': String}`.
class ResetPasswordController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late final String email;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    email = args is Map ? (args['email'] as String? ?? '') : '';
  }

  Future<void> savePassword() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    try {
      await _authRepository.updatePassword(passwordController.text);
      await SessionService.to.signOut();
      _backToLogin();
      globalSnackBar(
        title: 'Password updated',
        message: 'Sign in with your new password.',
      );
    } catch (e) {
      handleException(e, context: 'Reset password');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancel() async {
    if (isLoading.value) return;
    await SessionService.to.signOut();
    _backToLogin();
  }

  void _backToLogin() {
    var foundLogin = false;
    Get.until((route) {
      foundLogin = route.settings.name == Routes.LOGIN;
      return foundLogin || route.isFirst;
    });

    if (!foundLogin) {
      Get.offAllNamed(Routes.LOGIN, arguments: {'email': email});
      return;
    }
    if (Get.isRegistered<LoginController>() && email.isNotEmpty) {
      Get.find<LoginController>().emailController.text = email;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
