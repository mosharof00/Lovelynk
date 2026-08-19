import 'package:flutter/material.dart';

/// Weather shown by the Partner Weather widget.
class PartnerWeather {
  const PartnerWeather({
    required this.temperature,
    required this.condition,
    required this.icon,
  });

  /// Celsius.
  final int temperature;
  final String condition;

  /// Placeholder icon until the client supplies custom weather art.
  final IconData icon;
}

/// All dynamic values the 12 widgets render.
///
/// One immutable snapshot. Live values that change every second (counters,
/// partner time) are derived from this + the current time in the UI, so this
/// object only changes when the underlying relationship data changes.
///
/// Currently built from [WidgetData.mock]. Later this is filled from Supabase
/// (see `WidgetDataService.refreshFromBackend`).
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

  /// Straight-line distance between the two partners.
  final int distanceMiles;

  /// When the relationship started — drives Days Together + Together Counter.
  final DateTime togetherSince;

  /// Partner timezone as a simple UTC offset in hours (e.g. Sydney = +10).
  final int partnerUtcOffsetHours;
  final String partnerCity;

  final PartnerWeather partnerWeather;

  /// Next time the couple meets — drives Next Visit Countdown.
  final DateTime nextVisit;

  /// Anniversary date — drives the Anniversary widget.
  final DateTime anniversary;

  /// Direction (degrees, 0 = north) from the user toward the partner.
  final double compassBearing;
  final int compassMiles;

  String get userInitial =>
      userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  String get partnerInitial =>
      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?';

  /// Full days the couple has been together.
  int get daysTogether => DateTime.now().difference(togetherSince).inDays;

  /// Partner's current local time, derived from [now].
  DateTime partnerTime(DateTime now) =>
      now.toUtc().add(Duration(hours: partnerUtcOffsetHours));

  factory WidgetData.mock() {
    final now = DateTime.now();
    return WidgetData(
      userName: 'Jasper',
      partnerName: 'Milla',
      distanceMiles: 168,
      togetherSince: now.subtract(
        const Duration(days: 76, hours: 3, minutes: 27, seconds: 9),
      ),
      partnerUtcOffsetHours: 10,
      partnerCity: 'Sydney, Australia',
      partnerWeather: const PartnerWeather(
        temperature: 22,
        condition: 'Partly Cloudy',
        icon: Icons.cloud_queue_rounded,
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
