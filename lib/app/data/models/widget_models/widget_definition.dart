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
    this.isWide = false,
    this.sendLabel,
  });

  final AppWidgetType type;
  final WidgetCategory category;
  final String title;
  final String subtitle;

  /// Static fallback value used by the Customise preview chip.
  final String previewValue;
  final String previewUnit;

  /// SVG asset path from FlutterGen (`Assets.icons.*`).
  final String icon;

  /// Whether the card spans the full row (Partner Distance).
  final bool isWide;

  /// Footer action label for interactive widgets (e.g. "Send Kiss").
  final String? sendLabel;

  bool get isInteractive => category == WidgetCategory.interactive;

  String get id => type.id;
}
