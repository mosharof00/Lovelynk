import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/handle_exceptions.dart';
import '../../../../global/widgets/global_snackbar.dart';
import '../../../../core/services/session_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> register() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final email = emailController.text.trim().toLowerCase();
    isLoading.value = true;
    try {
      final outcome = await _authRepository.signUp(
        fullName: nameController.text,
        email: email,
        password: passwordController.text,
      );

      if (outcome == SignUpOutcome.signedIn) {
        await SessionService.to.load();
        Get.offAllNamed(Routes.CONNECT_WITH_PARTNER);
        return;
      }
      _openVerify(email);
    } on ApiException catch (e) {
      // Same unverified email signed up again within a minute: the earlier
      // code is still valid, so continue to verification.
      if (e.code == ApiErrorCode.emailRateLimit) {
        globalSnackBar(
          title: 'Code already sent',
          message: 'Use the code we sent to $email a moment ago.',
        );
        _openVerify(email);
        return;
      }
      handleException(e, context: 'Register');
    } catch (e) {
      handleException(e, context: 'Register');
    } finally {
      isLoading.value = false;
    }
  }

  void _openVerify(String email) {
    Get.toNamed(
      Routes.VERIFY_OTP,
      arguments: {'email': email, 'purpose': OtpPurpose.signup},
    );
  }

  void goToLogin() {
    Get.offNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
