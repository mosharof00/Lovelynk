/// The client's final 12 widgets.
enum AppWidgetType {
  // Essentials
  partnerDistance,
  daysTogether,
  togetherCounter,
  partnerTime,
  partnerWeather,
  nextVisitCountdown,

  // Relationship
  loveCompass,
  initials,
  anniversary,

  // Interactive
  heartbeat,
  kiss,
  emoji,
}

enum WidgetCategory {
  essentials,
  relationship,
  interactive,
}

extension WidgetCategoryX on WidgetCategory {
  String get title {
    switch (this) {
      case WidgetCategory.essentials:
        return 'Essentials';
      case WidgetCategory.relationship:
        return 'Relationship';
      case WidgetCategory.interactive:
        return 'Interactive';
    }
  }
}

extension AppWidgetTypeX on AppWidgetType {
  String get id {
    switch (this) {
      case AppWidgetType.partnerDistance:
        return 'partner_distance';
      case AppWidgetType.daysTogether:
        return 'days_together';
      case AppWidgetType.togetherCounter:
        return 'together_counter';
      case AppWidgetType.partnerTime:
        return 'partner_time';
      case AppWidgetType.partnerWeather:
        return 'partner_weather';
      case AppWidgetType.nextVisitCountdown:
        return 'next_visit_countdown';
      case AppWidgetType.loveCompass:
        return 'love_compass';
      case AppWidgetType.initials:
        return 'initials';
      case AppWidgetType.anniversary:
        return 'anniversary';
      case AppWidgetType.heartbeat:
        return 'heartbeat';
      case AppWidgetType.kiss:
        return 'kiss';
      case AppWidgetType.emoji:
        return 'emoji';
    }
  }

  static AppWidgetType? fromId(String id) {
    for (final type in AppWidgetType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}
