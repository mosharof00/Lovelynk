import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/handle_exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/utils/helper_utils.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../global/widgets/global_snackbar.dart';
import '../../../../routes/app_pages.dart';

/// Optional `Get.arguments = {'email': String}` to prefill (e.g. after reset).
class LoginController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] is String) {
      emailController.text = args['email'] as String;
    }
  }

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
      // Unverified accounts can't sign in; they must verify first.
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

  Future<void> _openVerification(String email) async {
    try {
      await _authRepository.resendOtp(email: email, purpose: OtpPurpose.signup);
    } on ApiException catch (e) {
      // A code was sent within the last minute; it is still valid.
      if (e.code != ApiErrorCode.emailRateLimit) {
        handleException(e, context: 'Resend OTP');
        return;
      }
    }
    globalSnackBar(
      title: 'Verify your email',
      message: 'Enter the code we sent to $email to activate your account.',
    );
    Get.toNamed(
      Routes.VERIFY_OTP,
      arguments: {'email': email, 'purpose': OtpPurpose.signup},
    );
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  void goToForgotPassword() {
    Get.toNamed(
      Routes.FORGOT_PASSWORD,
      arguments: {'email': emailController.text.trim()},
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
