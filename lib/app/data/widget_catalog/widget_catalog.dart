import '../../../gen/assets.gen.dart';
import '../models/widget_models/app_widget_type.dart';
import '../models/widget_models/widget_definition.dart';

/// Single source of truth for the client's final 12 widgets.
///
/// Icons here are placeholders from the current asset set; the client will
/// supply final custom art later (swap the `icon:` values then).
class WidgetCatalog {
  WidgetCatalog._();

  static final List<WidgetDefinition> all = [
    // ── Essentials ──────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.partnerDistance,
      category: WidgetCategory.essentials,
      title: 'Partner Distance',
      subtitle: 'How far apart you are right now',
      previewValue: '168',
      previewUnit: 'miles',
      icon: Assets.icons.diatanceIcon,
      isWide: true,
    ),
    WidgetDefinition(
      type: AppWidgetType.daysTogether,
      category: WidgetCategory.essentials,
      title: 'Days Together',
      subtitle: 'How many days you\'ve been together',
      previewValue: '76',
      previewUnit: 'days',
      icon: Assets.icons.loveIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.togetherCounter,
      category: WidgetCategory.essentials,
      title: 'Together Counter',
      subtitle: 'Live count of your time together',
      previewValue: '76:03:27:09',
      previewUnit: 'D : H : M : S',
      icon: Assets.icons.clockIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.partnerTime,
      category: WidgetCategory.essentials,
      title: 'Partner Time',
      subtitle: 'Your partner\'s local time',
      previewValue: '9:42',
      previewUnit: 'PM',
      icon: Assets.icons.clockIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.partnerWeather,
      category: WidgetCategory.essentials,
      title: 'Partner Weather',
      subtitle: 'Weather where your partner is',
      previewValue: '22°',
      previewUnit: 'Partly Cloudy',
      icon: Assets.icons.morningIcon,
    ),
    WidgetDefinition(
      type: AppWidgetType.nextVisitCountdown,
      category: WidgetCategory.essentials,
      title: 'Next Visit Countdown',
      subtitle: 'Countdown to your next visit',
      previewValue: '76:03:27:09',
      previewUnit: 'D : H : M : S',
      icon: Assets.icons.airplaneDepartureIcon,
    ),

    // ── Relationship ────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.loveCompass,
      category: WidgetCategory.relationship,
      title: 'Love Compass',
      subtitle: 'Points toward your partner',
      previewValue: '213',
      previewUnit: 'miles this way',
      icon: Assets.icons.loveIcon,
    ),
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
      type: AppWidgetType.anniversary,
      category: WidgetCategory.relationship,
      title: 'Anniversary',
      subtitle: 'Your special date + days to go',
      previewValue: '12 Oct 2025',
      previewUnit: '118 days to go',
      icon: Assets.icons.daysTogetherLoveIcon,
    ),

    // ── Interactive ─────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.heartbeat,
      category: WidgetCategory.interactive,
      title: 'Heartbeat',
      subtitle: 'Tap to send your heartbeat',
      previewValue: '💗',
      previewUnit: 'tap to send',
      icon: Assets.icons.heartbeatIcon,
      sendLabel: 'Send Heart',
    ),
    WidgetDefinition(
      type: AppWidgetType.kiss,
      category: WidgetCategory.interactive,
      title: 'Kiss',
      subtitle: 'One tap to send a kiss',
      previewValue: '💋',
      previewUnit: 'tap to send',
      icon: Assets.icons.kissIcon,
      sendLabel: 'Send Kiss',
    ),
    WidgetDefinition(
      type: AppWidgetType.emoji,
      category: WidgetCategory.interactive,
      title: 'Emoji',
      subtitle: 'Send emojis to your partner',
      previewValue: '😍',
      previewUnit: 'tap to send',
      icon: Assets.icons.moodsIcon,
      sendLabel: 'Send Emoji',
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
