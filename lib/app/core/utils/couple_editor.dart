import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/models/user_models/session_bootstrap.dart';
import '../../data/repositories/couple_repository.dart';
import '../../global/widgets/app_input_text_form_field.dart';
import '../../global/widgets/global_button.dart';
import '../../global/widgets/global_snackbar.dart';
import '../network/handle_exceptions.dart';
import '../services/session_service.dart';
import '../theme/app_color.dart';

/// Shared editors for couple fields (anniversary, next visit, nickname),
/// used from Home, Profile and Partner Profile. Changes sync to the
/// partner through `couple.updated`.
class CoupleEditor {
  CoupleEditor._();

  static ICoupleRepository get _repo => Get.find<ICoupleRepository>();

  static Future<void> editAnniversary(BuildContext context) async {
    final current = SessionService.to.couple?.togetherSince;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      helpText: 'When did you get together?',
      initialDate: current ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked == null || _sameDay(picked, current)) return;
    await _run(
      () => _repo.updateCouple(togetherSince: picked),
      success: 'Anniversary updated.',
    );
  }

  static Future<void> editNextVisit(BuildContext context) async {
    final current = SessionService.to.couple?.nextVisitAt?.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final hasUpcoming = current != null && !current.isBefore(today);

    final picked = await showDatePicker(
      context: context,
      helpText: 'When will you see each other next?',
      initialDate: hasUpcoming ? current : today,
      firstDate: today,
      lastDate: DateTime(now.year + 3, now.month, now.day),
    );
    if (picked == null || (hasUpcoming && _sameDay(picked, current))) return;
    await _run(
      () => _repo.updateCouple(nextVisit: picked),
      success: 'Next visit saved.',
    );
  }

  /// Picks a date directly, or offers Change / Remove when one is set.
  static Future<void> nextVisitActions(BuildContext context) async {
    final current = SessionService.to.couple?.nextVisitAt?.toLocal();
    final now = DateTime.now();
    final hasUpcoming =
        current != null &&
        !current.isBefore(DateTime(now.year, now.month, now.day));
    if (!hasUpcoming) return editNextVisit(context);

    final action = await Get.bottomSheet<String>(
      SafeArea(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_calendar_outlined),
                  title: const Text('Change date'),
                  onTap: () => Get.back(result: 'change'),
                ),
                ListTile(
                  leading: Icon(Icons.event_busy_outlined, color: AppColor.error),
                  title: Text(
                    'Remove next visit',
                    style: TextStyle(color: AppColor.error),
                  ),
                  onTap: () => Get.back(result: 'remove'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!context.mounted) return;
    if (action == 'change') await editNextVisit(context);
    if (action == 'remove') await clearNextVisit();
  }

  static Future<void> clearNextVisit() => _run(
    () => _repo.updateCouple(clearNextVisit: true),
    success: 'Next visit removed.',
  );

  static Future<void> editNickname() async {
    final partner = SessionService.to.partner;
    if (partner == null) return;

    final result = await Get.bottomSheet<String>(
      _NicknameSheet(
        partnerName: partner.fullName.trim(),
        initial: partner.nickname ?? '',
      ),
      isScrollControlled: true,
    );

    if (result == null || result == (partner.nickname ?? '')) return;
    await _run(
      () => _repo.updatePartnerNickname(result),
      success: 'Nickname updated.',
    );
  }

  static bool _sameDay(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  static Future<void> _run(
    Future<SessionBootstrap> Function() call, {
    required String success,
  }) async {
    Get.dialog(
      const Center(child: CupertinoActivityIndicator(radius: 14)),
      barrierDismissible: false,
    );
    try {
      final session = await call();
      SessionService.to.apply(session);
      Get.back();
      globalSnackBar(title: 'Saved', message: success);
    } catch (e) {
      Get.back();
      handleException(e, context: 'Update couple');
    }
  }
}

class _NicknameSheet extends StatefulWidget {
  const _NicknameSheet({required this.partnerName, required this.initial});

  final String partnerName;
  final String initial;

  @override
  State<_NicknameSheet> createState() => _NicknameSheetState();
}

class _NicknameSheetState extends State<_NicknameSheet> {
  late final _controller = TextEditingController(text: widget.initial);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Nickname for ${widget.partnerName.isEmpty ? 'your partner' : widget.partnerName}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                6.verticalSpace,
                Text(
                  'Only you see this name. Leave empty to use their own name.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
                16.verticalSpace,
                AppInputTextFormField(
                  controller: _controller,
                  hintText: 'e.g. Honey',
                  maxLength: 40,
                  validator: (v) => (v?.trim().length ?? 0) > 40
                      ? 'Use 40 characters or less'
                      : null,
                ),
                20.verticalSpace,
                GlobalButton(
                  text: 'Save',
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Get.back(result: _controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
