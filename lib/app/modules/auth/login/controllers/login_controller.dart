import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/handle_exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/helper_utils.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> login() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final email = emailController.text.trim().toLowerCase();
    isLoading.value = true;
    try {
      await _authRepository.signIn(
        email: email,
        password: passwordController.text,
      );
      await SessionService.to.load();
      await HelperUtils.initMainControllers();
      Get.offAllNamed(Routes.MAIN_PAGE);
    } on ApiException catch (e) {
      if (e.code == ApiErrorCode.emailNotConfirmed) {
        await _openVerification(email);
        return;
      }
      handleException(e, context: 'Login');
    } catch (e) {
      handleException(e, context: 'Login');
    } finally {
      isLoading.value = false;
    }
  }

  /// Account exists but the email was never verified: send a fresh code.
  Future<void> _openVerification(String email) async {
    try {
      await _authRepository.resendSignUpOtp(email);
    } on ApiException catch (e) {
      // A code was sent recently; the user can still enter it.
      if (e.code != 'over_email_send_rate_limit') {
        handleException(e, context: 'Resend OTP');
        return;
      }
    }
    Get.toNamed(Routes.VERIFY_OTP, arguments: {'email': email});
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
