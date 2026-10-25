import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../data/models/user_models/session_bootstrap.dart';
import '../../data/repositories/user_repository.dart';
import '../network/api_exception.dart';
import '../utils/logger.dart';
import 'session_service.dart';

/// Central service responsible for:
/// 1. Tracking device location with battery & server-optimized adaptive filtering.
/// 2. Reverse geocoding to city & country on-device.
/// 3. Uploading coordinates to Supabase via `update_my_location`.
/// 4. Managing location permission states (granted, denied, denied-forever, disabled service).
/// 5. Location sharing privacy toggle.
class LocationSyncService extends GetxService with WidgetsBindingObserver {
  static LocationSyncService get to => Get.find<LocationSyncService>();

  final isServiceEnabled = false.obs;
  final permission = Rx<LocationPermission>(LocationPermission.unableToDetermine);
  final isSharingEnabled = true.obs;
  final isUploading = false.obs;

  final currentPosition = Rxn<Position>();
  final currentCity = RxnString();
  final currentCountryCode = RxnString();
  final lastUploadTime = Rxn<DateTime>();
  final lastError = RxnString();

  StreamSubscription<Position>? _positionSub;
  Position? _lastUploadedPosition;
  Timer? _heartbeatTimer;
  bool _isSyncing = false;

  IUserRepository get _userRepo => Get.find<IUserRepository>();

  bool get hasPermission =>
      permission.value == LocationPermission.always ||
      permission.value == LocationPermission.whileInUse;

  bool get isDeniedForever =>
      permission.value == LocationPermission.deniedForever;

  bool get isReady =>
      isServiceEnabled.value && hasPermission && isSharingEnabled.value;

  String get statusMessage {
    if (!isServiceEnabled.value) {
      return 'Location services are turned off on your device.';
    }
    if (isDeniedForever) {
      return 'Location permission is denied. Tap to open Settings.';
    }
    if (permission.value == LocationPermission.denied) {
      return 'Location permission needed to show distance.';
    }
    if (!isSharingEnabled.value) {
      return 'Location sharing is paused.';
    }
    return 'Location sharing active.';
  }

  LocationSyncService init() {
    WidgetsBinding.instance.addObserver(this);

    // Sync sharing setting with SessionService
    if (SessionService.to.user != null) {
      isSharingEnabled.value = SessionService.to.isLocationSharingEnabled;
    }
    ever<SessionBootstrap?>(
      SessionService.to.bootstrap,
      (b) {
        if (b != null) {
          isSharingEnabled.value = b.user.locationSharingEnabled;
          if (hasPermission && isServiceEnabled.value && isSharingEnabled.value) {
            syncCurrentLocation();
            _startAdaptiveStream();
          }
        } else {
          _stopStream();
        }
      },
    );

    checkPermissionStatus().then((_) {
      if (SessionService.to.user != null &&
          hasPermission &&
          isServiceEnabled.value &&
          isSharingEnabled.value) {
        syncCurrentLocation();
        _startAdaptiveStream();
      }
    });

    return this;
  }

  /// Checks device GPS state and app permission without prompting.
  Future<void> checkPermissionStatus() async {
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      isServiceEnabled.value = service;

      final perm = await Geolocator.checkPermission();
      permission.value = perm;

      if (!service) {
        lastError.value = 'Device location is disabled.';
      } else if (perm == LocationPermission.deniedForever) {
        lastError.value = 'Location permission is denied forever.';
      } else {
        lastError.value = null;
      }
    } catch (e) {
      Log.w('Error checking location permission: $e');
    }
  }

  /// Prompts user for location permission with clear error feedback.
  Future<bool> requestPermission() async {
    final service = await Geolocator.isLocationServiceEnabled();
    isServiceEnabled.value = service;
    if (!service) {
      lastError.value = 'Please enable Location in your device Settings.';
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    permission.value = perm;

    if (perm == LocationPermission.deniedForever) {
      lastError.value = 'Permission permanently denied. Please allow in iOS Settings.';
      return false;
    }

    if (perm == LocationPermission.denied) {
      lastError.value = 'Location permission was denied.';
      return false;
    }

    lastError.value = null;
    await syncCurrentLocation(force: true);
    _startAdaptiveStream();
    return true;
  }

  /// Opens the device settings page for LoveLynk.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens device-level location services settings.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Toggles location sharing on/off on Supabase and updates local stream.
  Future<void> setSharingEnabled(bool enabled) async {
    try {
      isSharingEnabled.value = enabled;
      await _userRepo.setLocationSharing(enabled);

      if (enabled) {
        await checkPermissionStatus();
        if (hasPermission && isServiceEnabled.value) {
          await syncCurrentLocation(force: true);
          _startAdaptiveStream();
        }
      } else {
        _stopStream();
      }
    } catch (e) {
      Log.w('Failed to set location sharing: $e');
      // Revert on error
      isSharingEnabled.value = !enabled;
      rethrow;
    }
  }

  /// Foreground high-accuracy fix (e.g. app open, resume, pull-to-refresh).
  Future<void> syncCurrentLocation({bool force = false}) async {
    if (_isSyncing) return;
    if (!isSharingEnabled.value) return;

    final service = await Geolocator.isLocationServiceEnabled();
    isServiceEnabled.value = service;
    if (!service) return;

    final perm = await Geolocator.checkPermission();
    permission.value = perm;
    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      return;
    }

    _isSyncing = true;
    isUploading.value = true;

    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos != null) {
        currentPosition.value = pos;
        await _reverseGeocode(pos);
        await _uploadLocation(pos, force: force);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('syncCurrentLocation error: $e');
      }
    } finally {
      _isSyncing = false;
      isUploading.value = false;
    }
  }

  /// On-device reverse geocoding to resolve city & country code.
  Future<void> _reverseGeocode(Position pos) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality?.trim().isNotEmpty == true
            ? place.locality
            : (place.subAdministrativeArea?.trim().isNotEmpty == true
                ? place.subAdministrativeArea
                : place.administrativeArea);

        if (city != null && city.isNotEmpty) {
          currentCity.value = city;
        }
        if (place.isoCountryCode != null && place.isoCountryCode!.isNotEmpty) {
          currentCountryCode.value = place.isoCountryCode!.toUpperCase();
        }
      }
    } catch (e) {
      // Offline or Apple geocoding rate-limit: safe to ignore
      if (kDebugMode) {
        debugPrint('Reverse geocode note: $e');
      }
    }
  }

  /// Adaptive foreground stream based on movement speed.
  void _startAdaptiveStream() {
    _positionSub?.cancel();
    _heartbeatTimer?.cancel();

    if (!isReady) return;

    // Stream with medium accuracy and 50m filter
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
      ),
    ).listen(
      _onPositionUpdate,
      onError: (Object error) {
        Log.w('Location stream error: $error');
      },
    );

    // Heartbeat every 30 minutes while app is in foreground to keep data fresh even if still
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (isReady) {
        syncCurrentLocation(force: true);
      }
    });
  }

  void _onPositionUpdate(Position pos) {
    currentPosition.value = pos;

    final last = _lastUploadedPosition;
    final now = DateTime.now();

    if (last == null) {
      _uploadLocation(pos);
      return;
    }

    final distanceMeters = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      pos.latitude,
      pos.longitude,
    );

    final elapsedSeconds = lastUploadTime.value == null
        ? 999
        : now.difference(lastUploadTime.value!).inSeconds;

    // Discard readings with poor accuracy (> 100m)
    if (pos.accuracy > 100) return;

    // Speed in km/h
    final speedKmH = pos.speed * 3.6;

    bool shouldUpload = false;

    if (speedKmH > 120) {
      // High speed (train, plane): min 15 minutes or 3km
      if (elapsedSeconds >= 900 && distanceMeters >= 3000) {
        shouldUpload = true;
      }
    } else if (speedKmH > 25) {
      // Driving: min 3 minutes and at least 1km
      if (elapsedSeconds >= 180 && distanceMeters >= 1000) {
        shouldUpload = true;
      }
    } else {
      // Walking / moving locally: min 1 minute and at least 150m
      if (elapsedSeconds >= 60 && distanceMeters >= 150) {
        shouldUpload = true;
      }
    }

    if (shouldUpload) {
      _uploadLocation(pos);
    }
  }

  Future<void> _uploadLocation(Position pos, {bool force = false}) async {
    if (SessionService.to.user == null || !isSharingEnabled.value) return;

    // Local throttle guard (45 seconds) unless forced
    final now = DateTime.now();
    if (!force &&
        lastUploadTime.value != null &&
        now.difference(lastUploadTime.value!).inSeconds < 45) {
      return;
    }

    try {
      final res = await _userRepo.updateMyLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyM: pos.accuracy,
        city: currentCity.value,
        countryCode: currentCountryCode.value,
      );

      final accepted = res['accepted'] == true;
      if (accepted) {
        _lastUploadedPosition = pos;
        lastUploadTime.value = DateTime.now();
        lastError.value = null;
        if (kDebugMode) {
          debugPrint(
            'Location uploaded: (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}) '
            'city: ${currentCity.value}',
          );
        }
        // Keep weather cache synced for the partner
        unawaited(_userRepo.refreshWeather().catchError((e) {
          Log.w('Background weather refresh on location update failed: $e');
          return null;
        }));
      }
    } on ApiException catch (e) {
      Log.w('Location upload API exception: ${e.message}');
    } catch (e) {
      Log.w('Location upload error: $e');
    }
  }

  void _stopStream() {
    _positionSub?.cancel();
    _positionSub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        checkPermissionStatus().then((_) {
          if (isReady) {
            syncCurrentLocation();
            _startAdaptiveStream();
          }
        });
        break;
      case AppLifecycleState.paused:
        _stopStream();
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopStream();
    super.onClose();
  }
}
