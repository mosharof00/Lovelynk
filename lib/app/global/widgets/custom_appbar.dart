import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// A fully flexible, boilerplate-ready custom AppBar.
///
/// Usage examples:
///
/// 1. Simple title only:
///    CustomAppBar(title: 'Home')
///
/// 2. With back button:
///    CustomAppBar(title: 'Details', showBackButton: true)
///
/// 3. With action icons:
///    CustomAppBar(
///      title: 'Cart',
///      actions: [
///        AppBarAction(icon: Icons.search, onTap: () {}),
///        AppBarAction(icon: Icons.notifications_outlined, onTap: () {}, badgeCount: 3),
///      ],
///    )
///
/// 4. With custom leading widget:
///    CustomAppBar(
///      title: 'Profile',
///      leading: CircleAvatar(backgroundImage: NetworkImage(url)),
///    )
///
/// 5. With bottom widget (e.g. TabBar or search field):
///    CustomAppBar(
///      title: 'Products',
///      bottom: TabBar(...),
///    )
///
/// 6. Transparent / no shadow:
///    CustomAppBar(title: 'Feed', backgroundColor: Colors.transparent, elevation: 0)
///
/// 7. Centered or left-aligned title:
///    CustomAppBar(title: 'Orders', centerTitle: false)
///
/// 8. With subtitle:
///    CustomAppBar(title: 'Dashboard', subtitle: 'Welcome back 👋')
///
/// 9. Fully custom title widget:
///    CustomAppBar(titleWidget: MyLogoWidget())

class AppBarAction {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final Color? iconColor;
  final String? tooltip;

  const AppBarAction({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.iconColor,
    this.tooltip,
  });
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Text title — ignored if [titleWidget] is provided
  final String? title;

  final TextStyle? titleStyle;

  /// Optional subtitle shown below the title
  final String? subtitle;

  final TextStyle? subtitleStyle;

  /// Fully custom title widget — overrides [title] and [subtitle]
  final Widget? titleWidget;

  /// Custom leading widget — overrides [showBackButton]
  final Widget? leading;

  /// Show default back button (uses Get.back())
  final bool showBackButton;

  /// Right-side action buttons with optional badge support
  final List<AppBarAction>? actions;

  /// Bottom widget — e.g. TabBar, search field
  final PreferredSizeWidget? bottom;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final VoidCallback? onBackTap;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.showBackButton = false,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.systemOverlayStyle,
    this.onBackTap,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForeground =
        foregroundColor ?? theme.appBarTheme.foregroundColor ?? Colors.black87;
    final effectiveBackground =
        backgroundColor ?? theme.appBarTheme.backgroundColor;

    return AppBar(
      backgroundColor: effectiveBackground,
      foregroundColor: effectiveForeground,
      elevation: elevation,
      centerTitle: centerTitle,
      systemOverlayStyle: systemOverlayStyle,
      automaticallyImplyLeading: false,

      // ── Leading ──────────────────────────────────────────────
      leading: _buildLeading(context, effectiveForeground),

      // ── Title ────────────────────────────────────────────────
      title: titleWidget ?? _buildTitle(context, effectiveForeground),

      // ── Actions ──────────────────────────────────────────────
      actions: actions != null
          ? [
              ...actions!.map(
                (a) => _buildActionButton(a, effectiveForeground),
              ),
              SizedBox(width: 4.w),
            ]
          : null,

      // ── Bottom ───────────────────────────────────────────────
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: leading,
      );
    }
    if (showBackButton) {
      return _BackButton(
        color: foregroundColor,
        onTap: onBackTap ?? () => Get.back(),
      );
    }
    return null;
  }

  Widget _buildTitle(BuildContext context, Color foregroundColor) {
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title ?? '',
            style: titleStyle ?? Theme.of(context).appBarTheme.titleTextStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle!,
            style:
                subtitleStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.6),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    return Text(title ?? '', overflow: TextOverflow.ellipsis);
  }

  Widget _buildActionButton(AppBarAction action, Color foregroundColor) {
    final button = Tooltip(
      message: action.tooltip ?? '',
      child: IconButton(
        icon: Icon(action.icon),
        color: action.iconColor ?? foregroundColor,
        onPressed: action.onTap,
        splashRadius: 20.r,
      ),
    );

    if (action.badgeCount > 0) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: 6.w,
            top: 6.h,
            child: _Badge(count: action.badgeCount),
          ),
        ],
      );
    }
    return button;
  }
}

// ── Back Button ──────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _BackButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
      color: color,
      splashRadius: 20.r,
      onPressed: onTap,
      tooltip: 'Back',
    );
  }
}

// ── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.r),
      constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Convenience Presets ──────────────────────────────────────────────────────
// Optional shorthand constructors for the most common patterns in the app.

/// Simple titled AppBar with no back button
class AppBarTitle extends CustomAppBar {
  const AppBarTitle(String title, {super.key}) : super(title: title);
}

/// AppBar with back button
class AppBarBack extends CustomAppBar {
  const AppBarBack(String title, {super.key, super.onBackTap})
    : super(title: title, showBackButton: true);
}

/// AppBar with back button + right actions
class AppBarBackWithActions extends CustomAppBar {
  const AppBarBackWithActions(
    String title, {
    super.key,
    required List<AppBarAction> actions,
    super.onBackTap,
  }) : super(title: title, showBackButton: true, actions: actions);
}
