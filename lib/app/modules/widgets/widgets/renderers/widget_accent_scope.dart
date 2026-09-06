import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';

/// Optional accent override for widget body previews (Customise tab).
/// Falls back to [AppColor.primary] everywhere else.
class WidgetAccentScope extends InheritedWidget {
  const WidgetAccentScope({
    super.key,
    required this.accent,
    required super.child,
  });

  final Color accent;

  static Color of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<WidgetAccentScope>()
            ?.accent ??
        AppColor.primary;
  }

  @override
  bool updateShouldNotify(WidgetAccentScope oldWidget) =>
      accent != oldWidget.accent;
}
