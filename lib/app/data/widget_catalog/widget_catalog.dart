import '../../../gen/assets.gen.dart';
import '../models/widget_models/app_widget_type.dart';
import '../models/widget_models/widget_definition.dart';

/// Single source of truth for the final 12 widgets.
class WidgetCatalog {
  WidgetCatalog._();

  static final List<WidgetDefinition> all = [
    // ── Essentials ──────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.daysTogether,
      category: WidgetCategory.essentials,
      title: 'Days Together',
      subtitle: 'How many days you\'ve been together',
      previewValue: '83',
      previewUnit: 'days',
      icon: Assets.icons.daysTogetherLoveIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.distance,
      category: WidgetCategory.essentials,
      title: 'Our Distance',
      subtitle: 'Miles or km between cities',
      previewValue: '168',
      previewUnit: 'miles',
      icon: Assets.icons.diatanceIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.dualTimeZone,
      category: WidgetCategory.essentials,
      title: 'Partner Time',
      subtitle: 'Dual time zones at a glance',
      previewValue: '8:42',
      previewUnit: 'PM',
      icon: Assets.icons.clockIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.countdown,
      category: WidgetCategory.essentials,
      title: 'Countdown',
      subtitle: 'Visit, anniversary, or custom date',
      previewValue: '17',
      previewUnit: 'days to go',
      icon: Assets.icons.airplaneDepartureIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.goodMorningNight,
      category: WidgetCategory.essentials,
      title: 'Good Morning / Night',
      subtitle: 'Auto greeting by time of day',
      previewValue: 'GM',
      previewUnit: 'greeting',
      icon: Assets.icons.morningIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.photo,
      category: WidgetCategory.essentials,
      title: 'Photo',
      subtitle: 'Static shared photo, 4 layouts',
      previewValue: '📷',
      previewUnit: 'photo',
      icon: Assets.icons.photosIcon,
    ),

    // ── Relationship ────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.initials,
      category: WidgetCategory.relationship,
      title: 'Initials',
      subtitle: 'e.g. J ♥ M',
      previewValue: 'J♥M',
      previewUnit: 'initials',
      icon: Assets.icons.initialsIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.loveNote,
      category: WidgetCategory.relationship,
      title: 'Love Note',
      subtitle: '120 chars, syncs in real time',
      previewValue: 'I love you',
      previewUnit: 'note',
      icon: Assets.icons.noteSendIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.latestLoveNote,
      category: WidgetCategory.relationship,
      title: 'Latest Love Note',
      subtitle: 'Most recent note on your widget',
      previewValue: 'Miss you',
      previewUnit: 'latest',
      icon: Assets.icons.noteDoneIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.moodCheckIn,
      category: WidgetCategory.relationship,
      title: 'Partner Mood',
      subtitle: '8 moods, syncs to partner',
      previewValue: '😊',
      previewUnit: 'Happy',
      icon: Assets.icons.moodsIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.customText,
      category: WidgetCategory.relationship,
      title: 'Custom Text',
      subtitle: 'Your own short message',
      previewValue: 'Always',
      previewUnit: 'text',
      icon: Assets.icons.textIcon,
    ),

    // ── Interactive ─────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.sendKiss,
      category: WidgetCategory.interactive,
      title: 'Send Kiss',
      subtitle: 'One tap to send a kiss',
      previewValue: '💋',
      previewUnit: 'tap to send',
      icon: Assets.icons.kissIcon,
    ),
  ];

  static List<WidgetDefinition> byCategory(WidgetCategory category) {
    return all.where((w) => w.category == category).toList();
  }

  static WidgetDefinition? byType(AppWidgetType type) {
    for (final w in all) {
      if (w.type == type) return w;
    }
    return null;
  }

  static WidgetDefinition? byId(String id) {
    for (final w in all) {
      if (w.id == id) return w;
    }
    return null;
  }
}
