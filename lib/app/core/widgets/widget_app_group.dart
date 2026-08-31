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

  // ── Partner Distance data keys ──────────────────────────────────────────
  static const partnerDistanceMiles = 'partner_distance_miles';
  static const partnerDistanceUser = 'partner_distance_user_initial';
  static const partnerDistancePartner = 'partner_distance_partner_initial';

  // ── Anniversary data keys ───────────────────────────────────────────────
  static const anniversaryDateLabel = 'anniversary_date_label';
  static const anniversaryDaysToGo = 'anniversary_days_to_go';
}
