import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/widget_data_service.dart';
import '../../../data/models/widget_models/reaction_activity.dart';

class EmojiSummaryController extends GetxController {
  late final WidgetDataService _data;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<WidgetDataService>();
  }

  String get partnerName => _data.data.value.partnerName;

  int get fromPartner => _data.emojiCountFromPartner.value;
  int get fromMe => _data.emojiCountFromMe.value;

  List<ReactionActivity> get todayActivity => _data.emojiActivity;

  String timeLabel(DateTime at) => DateFormat('h:mm a').format(at);
}
