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
    required this.partnerUtcOffsetHours,
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
  final DateTime togetherSince;
  final int partnerUtcOffsetHours;
  final String partnerCity;
  final PartnerWeather partnerWeather;
  final DateTime nextVisit;
  final DateTime anniversary;
  final double compassBearing;
  final int compassMiles;

  String get userInitial =>
      userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  String get partnerInitial =>
      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?';

  int get daysTogether => DateTime.now().difference(togetherSince).inDays;

  DateTime partnerTime(DateTime now) =>
      now.toUtc().add(Duration(hours: partnerUtcOffsetHours));

  /// Real values from the session. Unpaired users get neutral defaults
  /// (0 days, 0 miles, no partner). Distance, compass and weather stay at
  /// defaults until the location / weather features are connected.
  factory WidgetData.fromSession(SessionBootstrap? session) {
    final now = DateTime.now();
    final couple = session?.couple;
    final partner = couple?.partner;
    final togetherSince = couple?.togetherSince ?? couple?.createdAt ?? now;
    final offsetMinutes =
        partner?.utcOffsetMinutes ?? now.timeZoneOffset.inMinutes;

    return WidgetData(
      userName: session?.user.firstName ?? '',
      partnerName: partner?.displayName ?? '',
      distanceMiles: 0,
      togetherSince: togetherSince,
      partnerUtcOffsetHours: (offsetMinutes / 60).round(),
      partnerCity: _cityFromTimezone(partner?.timezone),
      partnerWeather: PartnerWeather.fromOpenWeather(
        temperature: 0,
        condition: '--',
        conditionId: 803,
        iconCode: '04d',
      ),
      nextVisit: couple?.nextVisitAt ?? now,
      anniversary: couple?.togetherSince ?? now,
      compassBearing: 0,
      compassMiles: 0,
    );
  }

  /// "Australia/Sydney" → "Sydney".
  static String _cityFromTimezone(String? tz) {
    if (tz == null || !tz.contains('/')) return '';
    return tz.split('/').last.replaceAll('_', ' ');
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
      partnerUtcOffsetHours: 10,
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
    int? partnerUtcOffsetHours,
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
      partnerUtcOffsetHours: partnerUtcOffsetHours ?? this.partnerUtcOffsetHours,
      partnerCity: partnerCity ?? this.partnerCity,
      partnerWeather: partnerWeather ?? this.partnerWeather,
      nextVisit: nextVisit ?? this.nextVisit,
      anniversary: anniversary ?? this.anniversary,
      compassBearing: compassBearing ?? this.compassBearing,
      compassMiles: compassMiles ?? this.compassMiles,
    );
  }
}
