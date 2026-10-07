import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/handle_exceptions.dart';
import '../../../../core/services/session_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../global/widgets/global_snackbar.dart';
import '../../../../routes/app_pages.dart';

/// Expects `Get.arguments = {'email': String}`.
class VerifyOtpController extends GetxController {
  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();

  late final String email;

  final isVerifying = false.obs;
  final isResending = false.obs;
  final resendSeconds = 0.obs;

  Timer? _cooldownTimer;

  int get codeLength => AppConfig.emailOtpLength;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    email = args is Map ? (args['email'] as String? ?? '') : '';
    // A code was just sent by sign-up / login.
    _startCooldown();
  }

  void onCodeChanged(String value) {
    if (value.length == codeLength) verify();
  }

  Future<void> verify() async {
    if (isVerifying.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isVerifying.value = true;
    try {
      await _authRepository.verifySignUpOtp(
        email: email,
        token: codeController.text,
      );
      await SessionService.to.load();
      Get.offAllNamed(Routes.CONNECT_WITH_PARTNER);
    } catch (e) {
      codeController.clear();
      handleException(e, context: 'Verify OTP');
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resend() async {
    if (resendSeconds.value > 0 || isResending.value) return;
    isResending.value = true;
    try {
      await _authRepository.resendSignUpOtp(email);
      globalSnackBar(
        title: 'Code sent',
        message: 'We sent a new code to $email',
      );
      _startCooldown();
    } catch (e) {
      handleException(e, context: 'Resend OTP');
    } finally {
      isResending.value = false;
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    resendSeconds.value = AppConfig.otpResendCooldownSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    codeController.dispose();
    super.onClose();
  }
}
