import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/widget_data_service.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/widget_models/reaction_activity.dart';
import '../../widgets/widgets/dialogs/heartbeat_send_dialog.dart';

class HeartbeatSummaryController extends GetxController {
  late final WidgetDataService _data;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<WidgetDataService>();
  }

  String get partnerName => _data.data.value.partnerName;
  String get userName => _data.data.value.userName;

  int get fromPartner => _data.heartbeatsFromPartner.value;
  int get fromMe => _data.heartbeatsFromMe.value;

  List<ReactionActivity> get todayActivity => _data.heartbeatActivity;

  String timeLabel(DateTime at) => DateFormat('h:mm a').format(at);

  void onSendTap() {
    HeartbeatSendDialog.show(
      partnerName: partnerName,
      onSend: () {
        _data.sendHeartbeat();
        Get.snackbar(
          'Heartbeat sent 💗',
          'Let them know you\'re thinking of them.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColor.primaryLight,
          colorText: AppColor.textPrimary,
          margin: const EdgeInsets.all(16),
        );
      },
    );
  }
}
