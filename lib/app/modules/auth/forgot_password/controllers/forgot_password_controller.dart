import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/handle_exceptions.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../routes/app_pages.dart';

/// Optional `Get.arguments = {'email': String}` to prefill from Login.
class ForgotPasswordController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['email'] is String) {
      emailController.text = args['email'] as String;
    }
  }

  Future<void> sendCode() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final email = emailController.text.trim().toLowerCase();
    isLoading.value = true;
    try {
      await _authRepository.sendPasswordResetOtp(email);
      _openVerify(email);
    } on ApiException catch (e) {
      // A code was sent within the last minute; it is still valid.
      if (e.code == ApiErrorCode.emailRateLimit) {
        _openVerify(email);
        return;
      }
      handleException(e, context: 'Forgot password');
    } catch (e) {
      handleException(e, context: 'Forgot password');
    } finally {
      isLoading.value = false;
    }
  }

  void _openVerify(String email) {
    Get.toNamed(
      Routes.VERIFY_OTP,
      arguments: {'email': email, 'purpose': OtpPurpose.recovery},
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
