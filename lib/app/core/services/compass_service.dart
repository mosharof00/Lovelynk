import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../data/models/widget_models/app_widget_type.dart';
import '../widgets/widget_sync_service.dart';
import 'location_sync_service.dart';
import 'session_service.dart';

/// Live device heading + partner bearing for the Love Compass.
///
/// Needle angle = partnerBearing − deviceHeading.
/// Uses real partner coordinates from [SessionService] and real device location
/// from [LocationSyncService].
class CompassService extends GetxService {
  static CompassService get to => Get.find<CompassService>();

  /// Device heading in degrees (0–360, north = 0). Null until sensor ready.
  final heading = Rxn<double>();

  /// True when location permission was granted and a fix exists.
  final hasLocation = false.obs;

  /// False when the device has no compass stream (e.g. iOS Simulator).
  final hasCompass = true.obs;

  /// True if partner has an active, shared location.
  final isPartnerLocationAvailable = false.obs;

  /// True when partners are very close (< 80 meters).
  final isTogether = false.obs;

  /// Bearing (degrees) from me → partner (0–360).
  final partnerBearing = 0.0.obs;

  /// Distance in meters to partner. Null when locations unavailable.
  final partnerDistanceMeters = Rxn<double>();

  /// Miles to partner (derived).
  final partnerMiles = 0.obs;

  StreamSubscription<CompassEvent>? _headingSub;
  StreamSubscription<Position>? _localPosSub;
  Timer? _compassWidgetSyncDebounce;
  final _workers = <Worker>[];

  CompassService init() {
    final events = FlutterCompass.events;
    if (events == null) {
      hasCompass.value = false;
      if (kDebugMode) {
        debugPrint(
          'CompassService: no magnetometer stream '
          '(simulator or unsupported device). Using mock bearing.',
        );
      }
    } else {
      _headingSub = events.listen(
        (event) {
          final h = event.heading;
          if (h == null) return;
          heading.value = (h + 360) % 360;
        },
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint('CompassService heading stream error: $error');
          }
        },
      );
    }

    // Recompute when session or partner snapshot updates
    _workers.add(
      ever(SessionService.to.bootstrap, (_) => _recomputeBearingAndDistance()),
    );

    // Recompute when local position updates
    if (Get.isRegistered<LocationSyncService>()) {
      _workers.add(
        ever(
          LocationSyncService.to.currentPosition,
          (_) => _recomputeBearingAndDistance(),
        ),
      );
    }

    _recomputeBearingAndDistance();
    return this;
  }

  /// Called from Splash when user continues, or from permissions dialog.
  Future<bool> requestAndStartLocation() async {
    if (!Get.isRegistered<LocationSyncService>()) return false;
    final granted = await LocationSyncService.to.requestPermission();
    if (granted) {
      hasLocation.value = true;
      _recomputeBearingAndDistance();
    }
    return granted;
  }

  /// Recalculates bearing & distance between current user and partner.
  void _recomputeBearingAndDistance() {
    final session = SessionService.to;
    final partnerLive = session.partnerLive;
    final partnerLoc = partnerLive?.location;

    // Check if partner location sharing is active
    final partnerSharing = session.isPartnerLocationSharingEnabled;
    if (!partnerSharing || partnerLoc == null) {
      isPartnerLocationAvailable.value = false;
      isTogether.value = false;
      partnerDistanceMeters.value = null;

      // If server returned a snapshot distance/bearing fallback:
      if (partnerLive?.bearingDegrees != null) {
        partnerBearing.value = partnerLive!.bearingDegrees!;
      }
      if (partnerLive?.distanceKm != null) {
        final meters = partnerLive!.distanceKm! * 1000.0;
        partnerDistanceMeters.value = meters;
        partnerMiles.value = (meters / 1609.344).round();
      }
      return;
    }

    isPartnerLocationAvailable.value = true;

    final myPos = Get.isRegistered<LocationSyncService>()
        ? LocationSyncService.to.currentPosition.value
        : null;

    if (myPos == null) {
      // Use server snapshot fallback
      if (partnerLive?.bearingDegrees != null) {
        partnerBearing.value = partnerLive!.bearingDegrees!;
      }
      if (partnerLive?.distanceKm != null) {
        final meters = partnerLive!.distanceKm! * 1000.0;
        partnerDistanceMeters.value = meters;
        partnerMiles.value = (meters / 1609.344).round();
        isTogether.value = meters < 80;
      }
      return;
    }

    hasLocation.value = true;

    final bearing = Geolocator.bearingBetween(
      myPos.latitude,
      myPos.longitude,
      partnerLoc.latitude,
      partnerLoc.longitude,
    );
    partnerBearing.value = (bearing + 360.0) % 360.0;

    final meters = Geolocator.distanceBetween(
      myPos.latitude,
      myPos.longitude,
      partnerLoc.latitude,
      partnerLoc.longitude,
    );

    partnerDistanceMeters.value = meters;
    partnerMiles.value = (meters / 1609.344).round();
    isTogether.value = meters < 80;

    _scheduleLoveCompassWidgetSync();
  }

  /// Push live compass data to the native Love Compass widget (debounced).
  void _scheduleLoveCompassWidgetSync() {
    _compassWidgetSyncDebounce?.cancel();
    _compassWidgetSyncDebounce = Timer(const Duration(seconds: 2), () async {
      if (!Get.isRegistered<WidgetSyncService>()) return;
      await Get.find<WidgetSyncService>().syncWidget(AppWidgetType.loveCompass);
      if (kDebugMode) {
        debugPrint(
          'CompassService: synced Love Compass widget — '
          '${partnerMiles.value} mi, bearing ${partnerBearing.value.toStringAsFixed(0)}°',
        );
      }
    });
  }

  /// Needle rotation in radians for [Transform.rotate].
  double needleRadians() {
    final h = heading.value ?? 0;
    final bearing = partnerBearing.value;
    return (bearing - h) * math.pi / 180;
  }

  @override
  void onClose() {
    _compassWidgetSyncDebounce?.cancel();
    _headingSub?.cancel();
    _localPosSub?.cancel();
    for (final w in _workers) {
      w.dispose();
    }
    super.onClose();
  }
}
