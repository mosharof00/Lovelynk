import 'package:get/get.dart';

import 'local_store_service.dart';

enum DistanceUnit {
  miles('mi', 'Miles'),
  kilometers('km', 'Kilometres');

  const DistanceUnit(this.shortLabel, this.label);

  final String shortLabel;
  final String label;

  /// Converts a distance in miles to this unit.
  double fromMiles(double miles) =>
      this == DistanceUnit.miles ? miles : miles * 1.609344;

  /// Converts a distance in kilometers to this unit.
  double fromKilometers(double km) =>
      this == DistanceUnit.kilometers ? km : km * 0.621371;
}

enum TemperatureUnit {
  celsius('°C', 'Celsius'),
  fahrenheit('°F', 'Fahrenheit');

  const TemperatureUnit(this.symbol, this.label);

  final String symbol;
  final String label;

  /// Converts Celsius temperature to this unit.
  int fromCelsius(int c) =>
      this == TemperatureUnit.celsius ? c : ((c * 9 / 5) + 32).round();
}

/// Device-level display preferences (kept across accounts on this phone).
class UserPrefsService extends GetxService {
  static UserPrefsService get to => Get.find<UserPrefsService>();

  static const _unitKey = 'distance_unit';
  static const _tempKey = 'temperature_unit';

  final distanceUnit = DistanceUnit.miles.obs;
  final temperatureUnit = TemperatureUnit.celsius.obs;

  UserPrefsService init() {
    final storedDistance = HiveService.read<String>(_unitKey);
    distanceUnit.value = DistanceUnit.values.firstWhere(
      (u) => u.name == storedDistance,
      orElse: () => DistanceUnit.miles,
    );

    final storedTemp = HiveService.read<String>(_tempKey);
    temperatureUnit.value = TemperatureUnit.values.firstWhere(
      (u) => u.name == storedTemp,
      orElse: () => TemperatureUnit.celsius,
    );

    return this;
  }

  void setDistanceUnit(DistanceUnit unit) {
    distanceUnit.value = unit;
    HiveService.write(_unitKey, unit.name);
  }

  void setTemperatureUnit(TemperatureUnit unit) {
    temperatureUnit.value = unit;
    HiveService.write(_tempKey, unit.name);
  }
}
