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

  // ── Partner Time data keys ────────────────────────────────────────────────
  static const partnerTimeUtcOffsetHours = 'partner_time_utc_offset_hours';
  static const partnerTimeCity = 'partner_time_city';

  // ── Together Counter data keys ──────────────────────────────────────────
  static const togetherCounterSince = 'together_counter_since';

  // ── Next Visit Countdown data keys ──────────────────────────────────────
  static const nextVisitTargetAt = 'next_visit_target_at';

  // ── Partner Weather data keys ───────────────────────────────────────────
  static const partnerWeatherTemperature = 'partner_weather_temperature';
  static const partnerWeatherCondition = 'partner_weather_condition';
  static const partnerWeatherCity = 'partner_weather_city';
  static const partnerWeatherIconKey = 'partner_weather_icon_key';

  // ── Love Compass data keys ──────────────────────────────────────────────
  static const loveCompassMiles = 'love_compass_miles';
  static const loveCompassPartnerLabel = 'love_compass_partner_label';
  static const loveCompassNeedleDegrees = 'love_compass_needle_degrees';

  // ── Interactive widget data keys ────────────────────────────────────────
  static const heartbeatCount = 'heartbeat_count';
  static const kissCount = 'kiss_count';
  static const emojiRecent = 'emoji_recent';
}
