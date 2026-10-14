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
}

/// Device-level display preferences (kept across accounts on this phone).
class UserPrefsService extends GetxService {
  static UserPrefsService get to => Get.find<UserPrefsService>();

  static const _unitKey = 'distance_unit';

  final distanceUnit = DistanceUnit.miles.obs;

  UserPrefsService init() {
    final stored = HiveService.read<String>(_unitKey);
    distanceUnit.value = DistanceUnit.values.firstWhere(
      (u) => u.name == stored,
      orElse: () => DistanceUnit.miles,
    );
    return this;
  }

  void setDistanceUnit(DistanceUnit unit) {
    distanceUnit.value = unit;
    HiveService.write(_unitKey, unit.name);
  }
}
