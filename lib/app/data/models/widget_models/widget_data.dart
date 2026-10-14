import '../../../core/utils/time_zone_utils.dart';
import '../../../core/utils/weather_icon_mapper.dart';
import '../user_models/session_bootstrap.dart';

/// Weather shown by the Partner Weather widget.
class PartnerWeather {
  const PartnerWeather({
    required this.temperature,
    required this.condition,
    required this.iconPath,
    this.conditionId,
    this.isDay = true,
  });

  /// Celsius.
  final int temperature;
  final String condition;

  /// Custom SVG path (`Assets.weatherIcons.*`).
  final String iconPath;

  /// OpenWeather `weather[0].id` — used to re-map icon when data refreshes.
  final int? conditionId;
  final bool isDay;

  /// Build from OpenWeather API fields (Edge Function / Supabase later).
  factory PartnerWeather.fromOpenWeather({
    required int temperature,
    required String condition,
    required int conditionId,
    String? iconCode,
  }) {
    final isDay = WeatherIconMapper.isDayFromIconCode(iconCode);
    return PartnerWeather(
      temperature: temperature,
      condition: condition,
      conditionId: conditionId,
      isDay: isDay,
      iconPath: WeatherIconMapper.iconFor(
        conditionId: conditionId,
        isDay: isDay,
      ),
    );
  }
}

/// All dynamic values the 12 widgets render.
class WidgetData {
  const WidgetData({
    required this.userName,
    required this.partnerName,
    required this.distanceMiles,
    required this.togetherSince,
    required this.partnerTimezone,
    required this.partnerUtcOffsetMinutes,
    required this.partnerCity,
    required this.partnerWeather,
    required this.nextVisit,
    required this.anniversary,
    required this.compassBearing,
    required this.compassMiles,
  });

  final String userName;
  final String partnerName;
  final int distanceMiles;

  /// Null until the couple sets their anniversary.
  final DateTime? togetherSince;

  /// IANA zone, e.g. "Australia/Sydney". Preferred over the offset.
  final String? partnerTimezone;
  final int partnerUtcOffsetMinutes;
  final String partnerCity;
  final PartnerWeather partnerWeather;

  /// Null when no visit is planned.
  final DateTime? nextVisit;
  final DateTime? anniversary;
  final double compassBearing;
  final int compassMiles;

  String get userInitial =>
      userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  String get partnerInitial =>
      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?';

  int? get daysTogether {
    final since = togetherSince;
    if (since == null) return null;
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(since.year, since.month, since.day)).inDays;
  }

  /// Wall-clock time where the partner is (fields only; ignore isUtc).
  DateTime partnerTime(DateTime now) =>
      TimeZoneUtils.wallClock(
        timezone: partnerTimezone,
        utcOffsetMinutes: partnerUtcOffsetMinutes,
        at: now,
      ) ??
      now;

  /// Real values from the session. Unpaired users and unset dates get
  /// empty values so the UI can show "Set date". Distance, compass and
  /// weather stay at defaults until those features are connected.
  factory WidgetData.fromSession(SessionBootstrap? session) {
    final now = DateTime.now();
    final couple = session?.couple;
    final partner = couple?.partner;
    final visit = couple?.nextVisitAt;

    return WidgetData(
      userName: session?.user.firstName ?? '',
      partnerName: partner?.displayName ?? '',
      distanceMiles: 0,
      togetherSince: couple?.togetherSince,
      partnerTimezone: partner?.timezone,
      partnerUtcOffsetMinutes:
          TimeZoneUtils.offsetMinutes(
            partner?.timezone,
            fallback: partner?.utcOffsetMinutes,
          ) ??
          now.timeZoneOffset.inMinutes,
      partnerCity: TimeZoneUtils.cityFromTimezone(partner?.timezone) ?? '',
      partnerWeather: PartnerWeather.fromOpenWeather(
        temperature: 0,
        condition: '--',
        conditionId: 803,
        iconCode: '04d',
      ),
      nextVisit:
          visit == null ||
              visit.toLocal().isBefore(DateTime(now.year, now.month, now.day))
          ? null
          : visit,
      anniversary: couple?.togetherSince,
      compassBearing: 0,
      compassMiles: 0,
    );
  }

  factory WidgetData.mock() {
    final now = DateTime.now();
    return WidgetData(
      userName: 'Jasper',
      partnerName: 'Milla',
      distanceMiles: 1068,
      togetherSince: now.subtract(
        const Duration(days: 76, hours: 3, minutes: 27, seconds: 9),
      ),
      partnerTimezone: 'Australia/Sydney',
      partnerUtcOffsetMinutes: 600,
      partnerCity: 'Sydney, Australia',
      partnerWeather: PartnerWeather.fromOpenWeather(
        temperature: 22,
        condition: 'Partly Cloudy',
        conditionId: 802,
        iconCode: '03d',
      ),
      nextVisit: now.add(
        const Duration(days: 76, hours: 3, minutes: 27, seconds: 9),
      ),
      anniversary: DateTime(2025, 10, 12),
      compassBearing: 45,
      compassMiles: 213,
    );
  }

  WidgetData copyWith({
    String? userName,
    String? partnerName,
    int? distanceMiles,
    DateTime? togetherSince,
    String? partnerTimezone,
    int? partnerUtcOffsetMinutes,
    String? partnerCity,
    PartnerWeather? partnerWeather,
    DateTime? nextVisit,
    DateTime? anniversary,
    double? compassBearing,
    int? compassMiles,
  }) {
    return WidgetData(
      userName: userName ?? this.userName,
      partnerName: partnerName ?? this.partnerName,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      togetherSince: togetherSince ?? this.togetherSince,
      partnerTimezone: partnerTimezone ?? this.partnerTimezone,
      partnerUtcOffsetMinutes:
          partnerUtcOffsetMinutes ?? this.partnerUtcOffsetMinutes,
      partnerCity: partnerCity ?? this.partnerCity,
      partnerWeather: partnerWeather ?? this.partnerWeather,
      nextVisit: nextVisit ?? this.nextVisit,
      anniversary: anniversary ?? this.anniversary,
      compassBearing: compassBearing ?? this.compassBearing,
      compassMiles: compassMiles ?? this.compassMiles,
    );
  }
}
