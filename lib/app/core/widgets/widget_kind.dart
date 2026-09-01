import '../../data/models/widget_models/app_widget_type.dart';

/// Maps each [AppWidgetType] to its native WidgetKit `kind` string.
///
/// Only types with [hasNativeImplementation] == true are registered in the
/// iOS [LovelynkWidgetBundle] and refreshed via [WidgetSyncService].
class WidgetKind {
  WidgetKind._();

  static const daysTogether = 'DaysTogetherWidget';
  static const initials = 'InitialsWidget';
  static const partnerDistance = 'PartnerDistanceWidget';
  static const anniversary = 'AnniversaryWidget';
  static const partnerTime = 'PartnerTimeWidget';
  static const togetherCounter = 'TogetherCounterWidget';
  static const nextVisitCountdown = 'NextVisitCountdownWidget';
  static const partnerWeather = 'PartnerWeatherWidget';
  static const loveCompass = 'LoveCompassWidget';
  static const heartbeat = 'HeartbeatWidget';
  static const kiss = 'KissWidget';
  static const emoji = 'EmojiWidget';

  static String? iosKindFor(AppWidgetType type) {
    switch (type) {
      case AppWidgetType.daysTogether:
        return daysTogether;
      case AppWidgetType.initials:
        return initials;
      case AppWidgetType.partnerDistance:
        return partnerDistance;
      case AppWidgetType.anniversary:
        return anniversary;
      case AppWidgetType.partnerTime:
        return partnerTime;
      case AppWidgetType.togetherCounter:
        return togetherCounter;
      case AppWidgetType.nextVisitCountdown:
        return nextVisitCountdown;
      case AppWidgetType.partnerWeather:
        return partnerWeather;
      case AppWidgetType.loveCompass:
        return loveCompass;
      case AppWidgetType.heartbeat:
        return heartbeat;
      case AppWidgetType.kiss:
        return kiss;
      case AppWidgetType.emoji:
        return emoji;
    }
  }

  static bool hasNativeImplementation(AppWidgetType type) =>
      iosKindFor(type) != null;

  static List<String> get implementedKinds => [
        daysTogether,
        initials,
        partnerDistance,
        anniversary,
        partnerTime,
        togetherCounter,
        nextVisitCountdown,
        partnerWeather,
        loveCompass,
        heartbeat,
        kiss,
        emoji,
      ];
}
