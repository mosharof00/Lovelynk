enum SubscriptionStatus {
  /// Option B: all widgets unlocked during trial.
  trial,

  /// Paid subscription active — all unlocked.
  active,

  /// Trial ended / no sub — all locked (soft-lock for widgets later).
  expired,
}

class SubscriptionState {
  const SubscriptionState({
    required this.status,
    this.trialEndsAt,
  });

  final SubscriptionStatus status;
  final DateTime? trialEndsAt;

  bool get isWidgetsUnlocked =>
      status == SubscriptionStatus.trial || status == SubscriptionStatus.active;

  factory SubscriptionState.trial({Duration duration = const Duration(days: 7)}) {
    return SubscriptionState(
      status: SubscriptionStatus.trial,
      trialEndsAt: DateTime.now().add(duration),
    );
  }

  factory SubscriptionState.expired() =>
      const SubscriptionState(status: SubscriptionStatus.expired);

  factory SubscriptionState.active() =>
      const SubscriptionState(status: SubscriptionStatus.active);
}
