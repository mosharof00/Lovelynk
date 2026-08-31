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
  });

  final SubscriptionStatus status;
  final DateTime? trialEndsAt;
  final SubscriptionPlanId? planId;

  bool get isWidgetsUnlocked =>
      status == SubscriptionStatus.trial || status == SubscriptionStatus.active;

  /// Paid subscription only (not trial).
  bool get isPremium => status == SubscriptionStatus.active;

  bool get isOnTrial => status == SubscriptionStatus.trial;

  bool get isExpired => status == SubscriptionStatus.expired;

  int? get trialDaysRemaining {
    if (trialEndsAt == null) return null;
    final days = trialEndsAt!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  factory SubscriptionState.trial({Duration duration = const Duration(days: 7)}) {
    return SubscriptionState(
      status: SubscriptionStatus.trial,
      trialEndsAt: DateTime.now().add(duration),
    );
  }

  factory SubscriptionState.expired() =>
      const SubscriptionState(status: SubscriptionStatus.expired);

  factory SubscriptionState.active({SubscriptionPlanId? planId}) {
    return SubscriptionState(
      status: SubscriptionStatus.active,
      planId: planId,
    );
  }

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    DateTime? trialEndsAt,
    SubscriptionPlanId? planId,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      planId: planId ?? this.planId,
    );
  }

  Map<String, dynamic> toStorage() => {
        'status': status.name,
        'trialEndsAt': trialEndsAt?.toIso8601String(),
        'planId': planId?.name,
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

    return SubscriptionState(
      status: status,
      trialEndsAt:
          trialEndsRaw == null ? null : DateTime.tryParse(trialEndsRaw),
      planId: planId,
    );
  }
}
