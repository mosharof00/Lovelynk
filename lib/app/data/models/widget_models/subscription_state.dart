import '../user_models/session_bootstrap.dart';
import 'subscription_plan.dart';

enum SubscriptionStatus {
  /// Option B: all widgets unlocked during trial.
  trial,

  /// Paid subscription active — all unlocked.
  active,

  /// Trial ended / no sub — all locked.
  expired,
}

class SubscriptionState {
  const SubscriptionState({
    required this.status,
    this.trialEndsAt,
    this.planId,
    this.accessSource = AccessSource.none,
    this.expiresAt,
    this.willRenew,
  });

  final SubscriptionStatus status;
  final DateTime? trialEndsAt;
  final SubscriptionPlanId? planId;
  final AccessSource accessSource;
  final DateTime? expiresAt;
  final bool? willRenew;

  bool get isWidgetsUnlocked =>
      status == SubscriptionStatus.trial || status == SubscriptionStatus.active;

  /// Paid subscription only (not trial).
  bool get isPremium => status == SubscriptionStatus.active;

  bool get isOnTrial => status == SubscriptionStatus.trial;

  bool get isExpired => status == SubscriptionStatus.expired;

  bool get isPartnerShared => accessSource == AccessSource.partner;

  bool get isSelfPurchased => accessSource == AccessSource.self;

  int? get trialDaysRemaining {
    if (trialEndsAt == null) return null;
    final days = trialEndsAt!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  factory SubscriptionState.trial({
    Duration duration = const Duration(days: 7),
    AccessSource accessSource = AccessSource.self,
  }) {
    return SubscriptionState(
      status: SubscriptionStatus.trial,
      trialEndsAt: DateTime.now().add(duration),
      accessSource: accessSource,
    );
  }

  factory SubscriptionState.expired() =>
      const SubscriptionState(status: SubscriptionStatus.expired);

  factory SubscriptionState.active({
    SubscriptionPlanId? planId,
    AccessSource accessSource = AccessSource.self,
    DateTime? expiresAt,
    bool? willRenew,
  }) {
    return SubscriptionState(
      status: SubscriptionStatus.active,
      planId: planId,
      accessSource: accessSource,
      expiresAt: expiresAt,
      willRenew: willRenew,
    );
  }

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    DateTime? trialEndsAt,
    SubscriptionPlanId? planId,
    AccessSource? accessSource,
    DateTime? expiresAt,
    bool? willRenew,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      planId: planId ?? this.planId,
      accessSource: accessSource ?? this.accessSource,
      expiresAt: expiresAt ?? this.expiresAt,
      willRenew: willRenew ?? this.willRenew,
    );
  }

  Map<String, dynamic> toStorage() => {
        'status': status.name,
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'planId': planId?.name,
        'accessSource': accessSource.name,
        'expiresAt': expiresAt?.toIso8601String(),
        'willRenew': willRenew,
      };

  factory SubscriptionState.fromStorage(Map<dynamic, dynamic> map) {
    final statusName = map['status'] as String?;
    final status = SubscriptionStatus.values.firstWhere(
      (s) => s.name == statusName,
      orElse: () => SubscriptionStatus.expired,
    );
    final trialEndsRaw = map['trialEndsAt'] as String?;
    final planName = map['planId'] as String?;
    final planId = planName == null
        ? null
        : SubscriptionPlanId.values.firstWhere(
            (p) => p.name == planName,
            orElse: () => SubscriptionPlanId.monthly,
          );
    final sourceName = map['accessSource'] as String?;
    final accessSource = AccessSource.values.firstWhere(
      (s) => s.name == sourceName,
      orElse: () => AccessSource.none,
    );
    final expiresAtRaw = map['expiresAt'] as String?;

    return SubscriptionState(
      status: status,
      trialEndsAt:
          trialEndsRaw == null ? null : DateTime.tryParse(trialEndsRaw),
      planId: planId,
      accessSource: accessSource,
      expiresAt: expiresAtRaw == null ? null : DateTime.tryParse(expiresAtRaw),
      willRenew: map['willRenew'] as bool?,
    );
  }
}
