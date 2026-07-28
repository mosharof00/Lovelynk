enum AppWidgetType {
  daysTogether,
  distance,
  dualTimeZone,
  countdown,
  goodMorningNight,
  photo,
  initials,
  loveNote,
  latestLoveNote,
  moodCheckIn,
  customText,
  thinkingOfYou,
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
      case AppWidgetType.daysTogether:
        return 'days_together';
      case AppWidgetType.distance:
        return 'distance';
      case AppWidgetType.dualTimeZone:
        return 'dual_time_zone';
      case AppWidgetType.countdown:
        return 'countdown';
      case AppWidgetType.goodMorningNight:
        return 'good_morning_night';
      case AppWidgetType.photo:
        return 'photo';
      case AppWidgetType.initials:
        return 'initials';
      case AppWidgetType.loveNote:
        return 'love_note';
      case AppWidgetType.latestLoveNote:
        return 'latest_love_note';
      case AppWidgetType.moodCheckIn:
        return 'mood_check_in';
      case AppWidgetType.customText:
        return 'custom_text';
      case AppWidgetType.thinkingOfYou:
        return 'thinking_of_you';
    }
  }

  static AppWidgetType? fromId(String id) {
    for (final type in AppWidgetType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}
