import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_gradient.dart';
import 'custom_appbar.dart';

/// A drop-in replacement for [Scaffold] that paints the brand pink→blue
/// gradient background on every screen in light mode.
///
/// Dark mode falls back to [AppColor.darkBackground].
///
/// Usage — simple:
/// ```dart
/// AppScaffold(
///   appbarTitle: 'Home',
///   body: MyContent(),
/// )
/// ```
///
/// Usage — custom AppBar:
/// ```dart
/// AppScaffold(
///   appBar: CustomAppBar(title: 'Detail', showBackButton: true),
///   body: MyContent(),
/// )
/// ```
///
/// Usage — no AppBar (full-bleed):
/// ```dart
/// AppScaffold(body: MyContent())
/// ```
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.appbarTitle,
    this.backOnTap,
    this.showBackButton = true,
    this.actions,
    this.gradient,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = true,
  });

  final Widget body;

  /// Fully custom AppBar — overrides the built-in one.
  final PreferredSizeWidget? appBar;

  /// Convenience title for the built-in [CustomAppBar].
  /// Ignored when [appBar] is supplied.
  final String? appbarTitle;

  final VoidCallback? backOnTap;
  final bool showBackButton;
  final List<AppBarAction>? actions;

  /// Override the background gradient. Defaults to [AppGradient.appBgGradient].
  final Gradient? gradient;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAppBar = appBar != null || appbarTitle != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: hasAppBar && extendBodyBehindAppBar,
      appBar: appBar ??
          (appbarTitle != null
              ? CustomAppBar(
                  title: appbarTitle,
                  showBackButton: showBackButton,
                  onBackTap: backOnTap,
                  actions: actions,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                )
              : null),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? null : (gradient ?? AppGradient.appBgGradient),
          color: isDark ? AppColor.darkBackground : null,
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}
