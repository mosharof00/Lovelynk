/// App Group identifier — must match Runner + Widget Extension entitlements in Xcode.
class WidgetAppGroup {
  WidgetAppGroup._();

  static const id = 'group.com.lovelynk.app';

  // ── Global (subscription soft-lock) ─────────────────────────────────────
  static const globalLocked = 'widget_global_locked';
  static const globalLockMessage = 'widget_global_lock_message';

  // ── Per-widget style fields (suffix after `{widgetId}_`) ────────────────
  static const styleThemeColorId = 'themeColorId';
  static const styleUseBackground = 'useBackground';
  static const styleBackgroundColorId = 'backgroundColorId';
  static const styleFont = 'font';
  static const styleTextSize = 'textSize';

  static String styleKey(String widgetId, String field) => '${widgetId}_$field';

  // ── Days Together data keys ─────────────────────────────────────────────
  static const daysTogetherCount = 'days_together_count';
  static const daysTogetherTitle = 'days_together_title';
  // ── Initials data keys ────────────────────────────────────────────────
  static const initialsUser = 'initials_user_initial';
  static const initialsPartner = 'initials_partner_initial';
}
