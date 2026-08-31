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
      default:
        return null;
    }
  }

  static bool hasNativeImplementation(AppWidgetType type) =>
      iosKindFor(type) != null;

  static List<String> get implementedKinds => [
        daysTogether,
        initials,
        partnerDistance,
        anniversary,
      ];
}
