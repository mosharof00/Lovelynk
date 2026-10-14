import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wall-clock time in another user's zone. Prefers the IANA name
/// (DST-aware, handles +5:30 / +5:45) and falls back to a fixed offset.
class TimeZoneUtils {
  TimeZoneUtils._();

  static bool _ready = false;

  static void init() {
    if (_ready) return;
    tz_data.initializeTimeZones();
    _ready = true;
  }

  static tz.Location? _location(String? name) {
    if (name == null || name.isEmpty) return null;
    init();
    try {
      return tz.getLocation(name);
    } catch (_) {
      return null;
    }
  }

  /// Local time for [timezone] at [at] (now by default). The returned
  /// DateTime's fields are the wall-clock values; ignore its isUtc flag.
  static DateTime? wallClock({
    String? timezone,
    int? utcOffsetMinutes,
    DateTime? at,
  }) {
    final instant = (at ?? DateTime.now()).toUtc();
    final location = _location(timezone);
    if (location != null) {
      final local = tz.TZDateTime.from(instant, location);
      return DateTime.utc(
        local.year,
        local.month,
        local.day,
        local.hour,
        local.minute,
        local.second,
      );
    }
    if (utcOffsetMinutes == null) return null;
    return instant.add(Duration(minutes: utcOffsetMinutes));
  }

  /// Current UTC offset in minutes for [timezone] (falls back to [fallback]).
  static int? offsetMinutes(String? timezone, {int? fallback}) {
    final location = _location(timezone);
    if (location == null) return fallback;
    return tz.TZDateTime.now(location).timeZoneOffset.inMinutes;
  }

  /// "America/New_York" → "New York".
  static String? cityFromTimezone(String? timezone) {
    if (timezone == null || !timezone.contains('/')) return null;
    return timezone.split('/').last.replaceAll('_', ' ');
  }
}
