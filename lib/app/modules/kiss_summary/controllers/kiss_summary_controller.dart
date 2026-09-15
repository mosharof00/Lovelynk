import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/widget_data_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/reaction_activity.dart';
import '../../widgets/widgets/dialogs/kiss_send_dialog.dart';

class KissSummaryController extends GetxController {
  late final WidgetDataService _data;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<WidgetDataService>();
  }

  String get partnerName => _data.data.value.partnerName;

  int get fromPartner => _data.kissesFromPartner.value;
  int get fromMe => _data.kissesFromMe.value;

  List<ReactionActivity> get todayActivity => _data.kissActivity;

  String timeLabel(DateTime at) => DateFormat('h:mm a').format(at);

  void onSendTap() {
    KissSendDialog.show(
      partnerName: partnerName,
      onSend: () {
        _data.sendKiss();
        Get.snackbar(
          'Kiss sent 💋',
          'Your partner will feel the love.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.primaryLight,
          colorText: AppColor.textPrimary,
          margin: const EdgeInsets.all(16),
        );
      },
    );
  }
}
