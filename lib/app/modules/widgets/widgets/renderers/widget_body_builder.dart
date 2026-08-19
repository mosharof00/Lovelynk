import 'package:flutter/material.dart';

import '../../../../data/models/widget_models/app_widget_type.dart';
import 'essentials_widgets.dart';
import 'interactive_widgets.dart';
import 'relationship_widgets.dart';

/// Maps a widget type to its live body renderer. The body is the widget's
/// real look; the surrounding frame + footer come from [LoveWidgetCard].
Widget buildWidgetBody(AppWidgetType type) {
  switch (type) {
    case AppWidgetType.partnerDistance:
      return const PartnerDistanceWidget();
    case AppWidgetType.daysTogether:
      return const DaysTogetherWidget();
    case AppWidgetType.togetherCounter:
      return const TogetherCounterWidget();
    case AppWidgetType.partnerTime:
      return const PartnerTimeWidget();
    case AppWidgetType.partnerWeather:
      return const PartnerWeatherWidget();
    case AppWidgetType.nextVisitCountdown:
      return const NextVisitCountdownWidget();
    case AppWidgetType.loveCompass:
      return const LoveCompassWidget();
    case AppWidgetType.initials:
      return const InitialsWidget();
    case AppWidgetType.anniversary:
      return const AnniversaryWidget();
    case AppWidgetType.heartbeat:
      return const HeartbeatWidget();
    case AppWidgetType.kiss:
      return const KissWidget();
    case AppWidgetType.emoji:
      return const EmojiWidget();
  }
}
