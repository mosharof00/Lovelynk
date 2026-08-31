enum SubscriptionPlanId {
  monthly,
  yearly,
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.periodLabel,
    this.badge,
    this.savingsLabel,
  });

  final SubscriptionPlanId id;
  final String title;
  final int price;
  final String periodLabel;
  final String? badge;
  final String? savingsLabel;

  String get formattedPrice => '৳$price';

  static const monthly = SubscriptionPlan(
    id: SubscriptionPlanId.monthly,
    title: 'Monthly',
    price: 699,
    periodLabel: 'per month',
  );

  static const yearly = SubscriptionPlan(
    id: SubscriptionPlanId.yearly,
    title: 'Yearly',
    price: 2999,
    periodLabel: 'per year',
    badge: 'Best value',
    savingsLabel: 'Save 64%',
  );

  static const all = [monthly, yearly];

  static SubscriptionPlan? fromId(SubscriptionPlanId? id) {
    if (id == null) return null;
    return all.firstWhere((p) => p.id == id);
  }
}
