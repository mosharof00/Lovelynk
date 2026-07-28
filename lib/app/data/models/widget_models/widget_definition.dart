import 'package:flutter/material.dart';

import 'app_widget_type.dart';

class WidgetDefinition {
  const WidgetDefinition({
    required this.type,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.previewValue,
    required this.previewUnit,
    required this.icon,
  });

  final AppWidgetType type;
  final WidgetCategory category;
  final String title;
  final String subtitle;
  final String previewValue;
  final String previewUnit;
  final IconData icon;

  String get id => type.id;
}
