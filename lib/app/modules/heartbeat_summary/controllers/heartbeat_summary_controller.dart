import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/widget_data_service.dart';
import '../../../data/models/widget_models/reaction_activity.dart';

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

  void sendHeartbeat() {
    _data.sendHeartbeat();
  }
}
