import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/handle_exceptions.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/couple_models/pairing_invite.dart';
import '../../../data/repositories/couple_repository.dart';
import '../../../global/widgets/global_snackbar.dart';
import '../../../routes/app_pages.dart';
import '../widgets/all_set_dialog.dart';

/// Step 0 partner nickname → step 1 anniversary (skippable) → step 2 share
/// my code / enter theirs. Whoever enters the other's code pairs both; the
/// code owner is told via realtime (with polling as a fallback).
class ConnectWithPartnerController extends GetxController {
  final ICoupleRepository _coupleRepository = Get.find<ICoupleRepository>();

  final partnerNameController = TextEditingController();
  final partnerCodeController = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  final codeFormKey = GlobalKey<FormState>();

  final currentStep = 0.obs;
  final anniversaryDate = Rxn<DateTime>();

  final invite = Rxn<PairingInvite>();
  final isLoadingInvite = false.obs;
  final isConnecting = false.obs;
  final expiresLabel = ''.obs;

  static const totalSteps = 3;
  static const _pollInterval = Duration(seconds: 20);

  Timer? _expiryTimer;
  Timer? _pollTimer;
  StreamSubscription<CoupleEvent>? _coupleSub;
  bool _completed = false;

  String get inviteCode => invite.value?.code ?? '';

  /// "1234 5678" for readability.
  String get inviteCodeDisplay {
    final c = inviteCode;
    return c.length == 8 ? '${c.substring(0, 4)} ${c.substring(4)}' : c;
  }

  String get anniversaryLabel {
    final date = anniversaryDate.value;
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  void onInit() {
    super.onInit();
    _coupleSub = SessionService.to.coupleEvents.listen((event) {
      if (event == CoupleEvent.paired) _onPaired();
    });
  }

  // ── Step 0: nickname ──────────────────────────────────────────────

  void nextFromName() {
    if (!(nameFormKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    currentStep.value = 1;
  }

  // ── Step 1: anniversary ───────────────────────────────────────────

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

  void continueFromAnniversary() => _goToCodeStep();

  void skipAnniversary() {
    anniversaryDate.value = null;
    _goToCodeStep();
  }

  // ── Step 2: codes ─────────────────────────────────────────────────

  void _goToCodeStep() {
    currentStep.value = 2;
    loadInvite();
  }

  /// Gets my code (re-uses the open one, saving nickname / anniversary on it).
  Future<void> loadInvite() async {
    if (isLoadingInvite.value) return;
    isLoadingInvite.value = true;
    try {
      invite.value = await _coupleRepository.createInvite(
        partnerNickname: partnerNameController.text,
        togetherSince: anniversaryDate.value,
      );
      _startTimers();
    } catch (e) {
      handleException(e, context: 'Create invite');
    } finally {
      isLoadingInvite.value = false;
    }
  }

  Future<void> shareCode() async {
    final code = inviteCode;
    if (code.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(
        subject: 'Connect with me on Lovelynk',
        text: 'Connect with me on Lovelynk 💕\n'
            'Open the app and enter my code: $code\n'
            '(valid for 24 hours)',
      ),
    );
  }

  Future<void> copyCode() async {
    final code = inviteCode;
    if (code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    globalSnackBar(title: 'Copied', message: 'Your code is copied.');
  }

  Future<void> connect() async {
    if (isConnecting.value) return;
    if (!(codeFormKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();

    isConnecting.value = true;
    try {
      final session = await _coupleRepository.acceptInvite(
        code: partnerCodeController.text.replaceAll(' ', ''),
        partnerNickname: partnerNameController.text,
        togetherSince: anniversaryDate.value,
      );
      SessionService.to.apply(session);
      _onPaired();
    } catch (e) {
      handleException(e, context: 'Accept invite');
    } finally {
      isConnecting.value = false;
    }
  }

  void _startTimers() {
    _updateExpiry();
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateExpiry(),
    );

    // Fallback in case the realtime message is missed.
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (currentStep.value != 2 || _completed) return;
      await SessionService.to.refresh();
      if (SessionService.to.isPaired) _onPaired();
    });
  }

  void _updateExpiry() {
    final current = invite.value;
    expiresLabel.value = current?.expiresLabel ?? '';
    if (current != null && current.isExpired) {
      _expiryTimer?.cancel();
    }
  }

  void _stopTimers() {
    _expiryTimer?.cancel();
    _pollTimer?.cancel();
  }

  void _onPaired() {
    if (_completed) return;
    _completed = true;
    _stopTimers();
    Log.i('[Connect] Paired with ${SessionService.to.partner?.displayName}');
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
    skipForNow();
  }

  /// Opened from Home → just close. Opened right after sign-up (root route)
  /// → continue into the app unpaired.
  void skipForNow() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(Routes.MAIN_PAGE);
    }
  }

  @override
  void onClose() {
    _stopTimers();
    _coupleSub?.cancel();
    partnerNameController.dispose();
    partnerCodeController.dispose();
    super.onClose();
  }
}
