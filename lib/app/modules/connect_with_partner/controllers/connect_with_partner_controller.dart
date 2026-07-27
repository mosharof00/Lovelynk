import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../routes/app_pages.dart';
import '../widgets/all_set_dialog.dart';

class ConnectWithPartnerController extends GetxController {
  final partnerNameController = TextEditingController();
  final partnerCodeController = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  final codeFormKey = GlobalKey<FormState>();

  final currentStep = 0.obs;
  final anniversaryDate = Rxn<DateTime>();
  late final String inviteCode;

  static const totalSteps = 3;

  @override
  void onInit() {
    super.onInit();
    inviteCode = _generateInviteCode();
  }

  String _generateInviteCode() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(10)).join();
  }

  String get anniversaryLabel {
    final date = anniversaryDate.value;
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  void nextFromName() {
    if (!(nameFormKey.currentState?.validate() ?? false)) return;
    currentStep.value = 1;
  }

  Future<void> pickAnniversary(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: anniversaryDate.value ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      anniversaryDate.value = picked;
    }
  }

  void continueFromAnniversary() {
    currentStep.value = 2;
  }

  void skipAnniversary() {
    anniversaryDate.value = null;
    currentStep.value = 2;
  }

  void sendCode() {
    Get.snackbar(
      'Code sent',
      'Share this code with your partner: $inviteCode',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void connect() {
    if (!(codeFormKey.currentState?.validate() ?? false)) return;
    Get.dialog(
      AllSetDialog(onLetsGo: goToMain),
      barrierDismissible: false,
    );
  }

  void goToMain() {
    Get.back(); // close dialog
    Get.offAllNamed(Routes.MAIN_PAGE);
  }

  void back() {
    if (currentStep.value > 0) {
      currentStep.value--;
      return;
    }
    Get.back();
  }

  @override
  void onClose() {
    partnerNameController.dispose();
    partnerCodeController.dispose();
    super.onClose();
  }
}
