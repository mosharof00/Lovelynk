/// Response of the `get_session_bootstrap` RPC: everything the app needs
/// right after sign-in / on launch.
class SessionBootstrap {
  const SessionBootstrap({
    required this.user,
    required this.access,
    this.couple,
  });

  final AppUser user;
  final CoupleSummary? couple;
  final AccessStatus access;

  bool get isPaired => couple != null;

  factory SessionBootstrap.fromJson(Map<String, dynamic> json) {
    return SessionBootstrap(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      couple: json['couple'] == null
          ? null
          : CoupleSummary.fromJson(json['couple'] as Map<String, dynamic>),
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
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarPath;
  final String? timezone;
  final int? utcOffsetMinutes;
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
  });

  final String id;
  final String fullName;

  /// The nickname *I* gave my partner.
  final String? nickname;
  final String? avatarPath;
  final String? timezone;
  final int? utcOffsetMinutes;

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
