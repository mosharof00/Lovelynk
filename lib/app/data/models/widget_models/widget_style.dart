import 'package:flutter/material.dart';

enum WidgetTextSize { small, medium, large }

enum WidgetSystemFont { sfPro, sfProRounded, newYork }

class WidgetThemeColor {
  const WidgetThemeColor({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;
}

class WidgetStyle {
  const WidgetStyle({
    required this.themeColorId,
    required this.useBackground,
    required this.backgroundColorId,
    required this.font,
    required this.textSize,
  });

  final String themeColorId;
  final bool useBackground;
  final String backgroundColorId;
  final WidgetSystemFont font;
  final WidgetTextSize textSize;

  factory WidgetStyle.defaults() => const WidgetStyle(
        themeColorId: 'rose',
        useBackground: false,
        backgroundColorId: 'rose',
        font: WidgetSystemFont.sfPro,
        textSize: WidgetTextSize.medium,
      );

  WidgetStyle copyWith({
    String? themeColorId,
    bool? useBackground,
    String? backgroundColorId,
    WidgetSystemFont? font,
    WidgetTextSize? textSize,
  }) {
    return WidgetStyle(
      themeColorId: themeColorId ?? this.themeColorId,
      useBackground: useBackground ?? this.useBackground,
      backgroundColorId: backgroundColorId ?? this.backgroundColorId,
      font: font ?? this.font,
      textSize: textSize ?? this.textSize,
    );
  }

  Map<String, String> toStorageMap() => {
        'themeColorId': themeColorId,
        'useBackground': useBackground ? '1' : '0',
        'backgroundColorId': backgroundColorId,
        'font': font.name,
        'textSize': textSize.name,
      };

  factory WidgetStyle.fromStorageMap(Map<String, String?> map) {
    final defaults = WidgetStyle.defaults();
    return WidgetStyle(
      themeColorId: map['themeColorId'] ?? defaults.themeColorId,
      useBackground: map['useBackground'] == '1',
      backgroundColorId: map['backgroundColorId'] ?? defaults.backgroundColorId,
      font: WidgetSystemFont.values.firstWhere(
        (f) => f.name == map['font'],
        orElse: () => defaults.font,
      ),
      textSize: WidgetTextSize.values.firstWhere(
        (s) => s.name == map['textSize'],
        orElse: () => defaults.textSize,
      ),
    );
  }
}

extension WidgetSystemFontX on WidgetSystemFont {
  String get label {
    switch (this) {
      case WidgetSystemFont.sfPro:
        return 'SF Pro';
      case WidgetSystemFont.sfProRounded:
        return 'SF Pro Rounded';
      case WidgetSystemFont.newYork:
        return 'New York';
    }
  }

  /// Flutter preview mapping (WidgetKit will use real system fonts later).
  String? get fontFamily {
    switch (this) {
      case WidgetSystemFont.sfPro:
        return null; // platform default
      case WidgetSystemFont.sfProRounded:
        return '.SF Pro Rounded';
      case WidgetSystemFont.newYork:
        return 'New York';
    }
  }
}

extension WidgetTextSizeX on WidgetTextSize {
  String get label {
    switch (this) {
      case WidgetTextSize.small:
        return 'Small';
      case WidgetTextSize.medium:
        return 'Medium';
      case WidgetTextSize.large:
        return 'Large';
    }
  }

  double get previewFontSize {
    switch (this) {
      case WidgetTextSize.small:
        return 22;
      case WidgetTextSize.medium:
        return 28;
      case WidgetTextSize.large:
        return 34;
    }
  }
}

class WidgetStyleOptions {
  WidgetStyleOptions._();

  static const String customPrefix = 'custom_';

  static const List<WidgetThemeColor> themeColors = [
    WidgetThemeColor(id: 'rose', label: 'Rose', color: Color(0xFFFF4FA3)),
    WidgetThemeColor(id: 'sky', label: 'Sky', color: Color(0xFF42C2FF)),
    WidgetThemeColor(id: 'lavender', label: 'Lavender', color: Color(0xFF9B7EDE)),
    WidgetThemeColor(id: 'peach', label: 'Peach', color: Color(0xFFFF8F6B)),
    WidgetThemeColor(id: 'mint', label: 'Mint', color: Color(0xFF4ECDC4)),
    WidgetThemeColor(id: 'ink', label: 'Ink', color: Color(0xFF1A1530)),
  ];

  static bool isCustomId(String id) => id.startsWith(customPrefix);

  static String colorToCustomId(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '$customPrefix$value';
  }

  static Color? tryParseCustomId(String id) {
    if (!isCustomId(id)) return null;
    final hex = id.substring(customPrefix.length);
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  static WidgetThemeColor byId(String id) {
    for (final c in themeColors) {
      if (c.id == id) return c;
    }
    final custom = tryParseCustomId(id);
    if (custom != null) {
      return WidgetThemeColor(id: id, label: 'Custom', color: custom);
    }
    return themeColors.first;
  }
}
