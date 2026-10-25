/// Response of the `get_session_bootstrap` RPC: everything the app needs
/// right after sign-in / on launch.
class SessionBootstrap {
  const SessionBootstrap({
    required this.user,
    required this.access,
    this.couple,
    this.partnerLive,
  });

  final AppUser user;
  final CoupleSummary? couple;
  final AccessStatus access;
  final PartnerLiveSnapshot? partnerLive;

  bool get isPaired => couple != null;

  factory SessionBootstrap.fromJson(Map<String, dynamic> json) {
    return SessionBootstrap(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      couple: json['couple'] == null
          ? null
          : CoupleSummary.fromJson(json['couple'] as Map<String, dynamic>),
      partnerLive: json['partner_live'] == null
          ? null
          : PartnerLiveSnapshot.fromJson(
              json['partner_live'] as Map<String, dynamic>,
            ),
      access: AccessStatus.fromJson(
        (json['access'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.createdAt,
    this.avatarPath,
    this.timezone,
    this.utcOffsetMinutes,
    this.locationSharingEnabled = true,
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarPath;
  final String? timezone;
  final int? utcOffsetMinutes;
  final bool locationSharingEnabled;
  final DateTime createdAt;

  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      avatarPath: json['avatar_path'] as String?,
      timezone: json['timezone'] as String?,
      utcOffsetMinutes: json['utc_offset_minutes'] as int?,
      locationSharingEnabled:
          (json['location_sharing_enabled'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CoupleSummary {
  const CoupleSummary({
    required this.id,
    required this.partner,
    required this.createdAt,
    this.togetherSince,
    this.nextVisitAt,
  });

  final String id;
  final DateTime? togetherSince;
  final DateTime? nextVisitAt;
  final DateTime createdAt;
  final PartnerSummary partner;

  factory CoupleSummary.fromJson(Map<String, dynamic> json) {
    return CoupleSummary(
      id: json['id'] as String,
      togetherSince: _parseDate(json['together_since']),
      nextVisitAt: _parseDate(json['next_visit_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      partner: PartnerSummary.fromJson(json['partner'] as Map<String, dynamic>),
    );
  }
}

class PartnerSummary {
  const PartnerSummary({
    required this.id,
    required this.fullName,
    this.nickname,
    this.avatarPath,
    this.timezone,
    this.utcOffsetMinutes,
    this.locationSharingEnabled = true,
  });

  final String id;
  final String fullName;

  /// The nickname *I* gave my partner.
  final String? nickname;
  final String? avatarPath;
  final String? timezone;
  final int? utcOffsetMinutes;
  final bool locationSharingEnabled;

  /// Nickname first, then the partner's own name.
  String get displayName {
    final nick = nickname?.trim() ?? '';
    if (nick.isNotEmpty) return nick;
    return fullName.trim();
  }

  factory PartnerSummary.fromJson(Map<String, dynamic> json) {
    return PartnerSummary(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      nickname: json['nickname'] as String?,
      avatarPath: json['avatar_path'] as String?,
      timezone: json['timezone'] as String?,
      utcOffsetMinutes: json['utc_offset_minutes'] as int?,
      locationSharingEnabled:
          (json['location_sharing_enabled'] as bool?) ?? true,
    );
  }
}

/// Live partner snapshot returned by get_partner_snapshot / get_session_bootstrap.
class PartnerLiveSnapshot {
  const PartnerLiveSnapshot({
    required this.partnerId,
    required this.locationSharingEnabled,
    this.location,
    this.distanceKm,
    this.bearingDegrees,
    this.timezone,
    this.utcOffsetMinutes,
    this.weather,
    this.serverNow,
  });

  final String partnerId;
  final bool locationSharingEnabled;
  final PartnerLiveLocation? location;
  final double? distanceKm;
  final double? bearingDegrees;
  final String? timezone;
  final int? utcOffsetMinutes;
  final PartnerLiveWeather? weather;
  final DateTime? serverNow;

  double? get distanceMiles =>
      distanceKm == null ? null : distanceKm! * 0.621371;

  factory PartnerLiveSnapshot.fromJson(Map<String, dynamic> json) {
    return PartnerLiveSnapshot(
      partnerId: (json['partner_id'] as String?) ?? '',
      locationSharingEnabled:
          (json['location_sharing_enabled'] as bool?) ?? true,
      location: json['location'] == null
          ? null
          : PartnerLiveLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      bearingDegrees: (json['bearing_degrees'] as num?)?.toDouble(),
      timezone: json['timezone'] as String?,
      utcOffsetMinutes: json['utc_offset_minutes'] as int?,
      weather: json['weather'] == null
          ? null
          : PartnerLiveWeather.fromJson(
              json['weather'] as Map<String, dynamic>,
            ),
      serverNow: _parseDate(json['server_now']),
    );
  }
}

class PartnerLiveLocation {
  const PartnerLiveLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyM,
    this.city,
    this.countryCode,
    this.updatedAt,
  });

  final double latitude;
  final double longitude;
  final double? accuracyM;
  final String? city;
  final String? countryCode;
  final DateTime? updatedAt;

  factory PartnerLiveLocation.fromJson(Map<String, dynamic> json) {
    return PartnerLiveLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyM: (json['accuracy_m'] as num?)?.toDouble(),
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      updatedAt: _parseDate(json['updated_at']),
    );
  }
}

class PartnerLiveWeather {
  const PartnerLiveWeather({
    required this.temperatureC,
    required this.condition,
    required this.conditionId,
    required this.iconCode,
    this.fetchedAt,
  });

  final int temperatureC;
  final String condition;
  final int conditionId;
  final String iconCode;
  final DateTime? fetchedAt;

  factory PartnerLiveWeather.fromJson(Map<String, dynamic> json) {
    return PartnerLiveWeather(
      temperatureC: (json['temperature_c'] as num?)?.toInt() ?? 0,
      condition: (json['condition'] as String?) ?? '',
      conditionId: (json['condition_id'] as num?)?.toInt() ?? 800,
      iconCode: (json['icon_code'] as String?) ?? '01d',
      fetchedAt: _parseDate(json['fetched_at']),
    );
  }
}

enum AccessSource { self, partner, none }

/// Response of `get_my_access` (also embedded in the bootstrap).
class AccessStatus {
  const AccessStatus({
    required this.isPremium,
    required this.source,
    required this.isTrial,
    this.plan,
    this.status,
    this.expiresAt,
    this.willRenew,
  });

  final bool isPremium;
  final AccessSource source;
  final bool isTrial;

  /// `monthly` / `yearly`.
  final String? plan;
  final String? status;
  final DateTime? expiresAt;

  /// Only known when [source] is [AccessSource.self].
  final bool? willRenew;

  factory AccessStatus.fromJson(Map<String, dynamic> json) {
    return AccessStatus(
      isPremium: (json['is_premium'] as bool?) ?? false,
      source: AccessSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => AccessSource.none,
      ),
      isTrial: (json['is_trial'] as bool?) ?? false,
      plan: json['plan'] as String?,
      status: json['status'] as String?,
      expiresAt: _parseDate(json['expires_at']),
      willRenew: json['will_renew'] as bool?,
    );
  }
}

DateTime? _parseDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(value as String);
