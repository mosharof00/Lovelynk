import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Live device heading + optional location for the Love Compass.
///
/// Needle angle = partnerBearing − deviceHeading.
/// Location is started from Splash after the user taps Continue.
///
/// **iOS note:** You may see a console message like
/// "Swift Package Manager is not supported for iOS" from Flutter tooling.
/// [flutter_compass] ships as a CocoaPod (see `ios/Podfile.lock`) — the
/// warning is harmless and the compass still works on a physical device.
/// Simulators have no magnetometer, so heading stays at mock values there.
class CompassService extends GetxService {
  /// Device heading in degrees (0–360, north = 0). Null until sensor ready.
  final heading = Rxn<double>();

  /// True when location permission was granted and a fix exists.
  final hasLocation = false.obs;

  /// False when the device has no compass stream (e.g. iOS Simulator).
  final hasCompass = true.obs;

  StreamSubscription<CompassEvent>? _headingSub;
  StreamSubscription<Position>? _positionSub;

  /// Mock partner coords (Sydney). Replaced by Supabase later.
  static const double partnerLat = -33.8688;
  static const double partnerLng = 151.2093;

  double? _myLat;
  double? _myLng;

  /// Bearing (degrees) from me → partner. Falls back to mock when no GPS.
  final partnerBearing = 45.0.obs;

  /// Haversine miles to partner. Falls back to mock when no GPS.
  final partnerMiles = 213.obs;

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
      return this;
    }

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
    // Location starts only after Splash permission Continue.
    return this;
  }

  /// Called from Splash when the user taps Continue on the permission dialog.
  Future<bool> requestAndStartLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    await _listenPosition();
    return true;
  }

  Future<void> _listenPosition() async {
    if (_positionSub != null) return;
    hasLocation.value = true;
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 25,
      ),
    ).listen(_onPosition);
  }

  void _onPosition(Position pos) {
    _myLat = pos.latitude;
    _myLng = pos.longitude;
    partnerBearing.value = Geolocator.bearingBetween(
      _myLat!,
      _myLng!,
      partnerLat,
      partnerLng,
    );
    final meters = Geolocator.distanceBetween(
      _myLat!,
      _myLng!,
      partnerLat,
      partnerLng,
    );
    partnerMiles.value = (meters / 1609.344).round();
  }

  /// Needle rotation in radians for [Transform.rotate].
  double needleRadians() {
    final h = heading.value ?? 0;
    final bearing = partnerBearing.value;
    return (bearing - h) * math.pi / 180;
  }

  @override
  void onClose() {
    _headingSub?.cancel();
    _positionSub?.cancel();
    super.onClose();
  }
}
