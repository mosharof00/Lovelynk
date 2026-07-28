import 'package:flutter/material.dart';

import '../models/widget_models/app_widget_type.dart';
import '../models/widget_models/widget_definition.dart';

/// Single source of truth for the final 12 widgets.
class WidgetCatalog {
  WidgetCatalog._();

  static const List<WidgetDefinition> all = [
    // ── Essentials ──────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.daysTogether,
      category: WidgetCategory.essentials,
      title: 'Days Together',
      subtitle: 'How many days you\'ve been together',
      previewValue: '83',
      previewUnit: 'days',
      icon: Icons.favorite_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.distance,
      category: WidgetCategory.essentials,
      title: 'Our Distance',
      subtitle: 'Miles or km between cities',
      previewValue: '168',
      previewUnit: 'miles',
      icon: Icons.place_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.dualTimeZone,
      category: WidgetCategory.essentials,
      title: 'Partner Time',
      subtitle: 'Dual time zones at a glance',
      previewValue: '8:42',
      previewUnit: 'PM',
      icon: Icons.schedule_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.countdown,
      category: WidgetCategory.essentials,
      title: 'Countdown',
      subtitle: 'Visit, anniversary, or custom date',
      previewValue: '17',
      previewUnit: 'days to go',
      icon: Icons.flight_takeoff_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.goodMorningNight,
      category: WidgetCategory.essentials,
      title: 'Good Morning / Night',
      subtitle: 'Auto greeting by time of day',
      previewValue: 'GM',
      previewUnit: 'greeting',
      icon: Icons.wb_sunny_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.photo,
      category: WidgetCategory.essentials,
      title: 'Photo',
      subtitle: 'Static shared photo, 4 layouts',
      previewValue: '📷',
      previewUnit: 'photo',
      icon: Icons.photo_rounded,
    ),

    // ── Relationship ────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.initials,
      category: WidgetCategory.relationship,
      title: 'Initials',
      subtitle: 'e.g. J ♥ M',
      previewValue: 'J♥M',
      previewUnit: 'initials',
      icon: Icons.favorite_border_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.loveNote,
      category: WidgetCategory.relationship,
      title: 'Love Note',
      subtitle: '120 chars, syncs in real time',
      previewValue: 'I love you',
      previewUnit: 'note',
      icon: Icons.mail_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.latestLoveNote,
      category: WidgetCategory.relationship,
      title: 'Latest Love Note',
      subtitle: 'Most recent note on your widget',
      previewValue: 'Miss you',
      previewUnit: 'latest',
      icon: Icons.mark_email_read_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.moodCheckIn,
      category: WidgetCategory.relationship,
      title: 'Partner Mood',
      subtitle: '8 moods, syncs to partner',
      previewValue: '😊',
      previewUnit: 'Happy',
      icon: Icons.emoji_emotions_rounded,
    ),
    WidgetDefinition(
      type: AppWidgetType.customText,
      category: WidgetCategory.relationship,
      title: 'Custom Text',
      subtitle: 'Your own short message',
      previewValue: 'Always',
      previewUnit: 'text',
      icon: Icons.text_fields_rounded,
    ),

    // ── Interactive ─────────────────────────────────────
    WidgetDefinition(
      type: AppWidgetType.thinkingOfYou,
      category: WidgetCategory.interactive,
      title: 'Thinking of You',
      subtitle: 'One tap until dismissed',
      previewValue: '💭',
      previewUnit: 'tap to send',
      icon: Icons.psychology_rounded,
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
