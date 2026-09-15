enum SubscriptionPlanId {
  monthly,
  yearly,
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.billingLine,
    required this.perUserLine,
    required this.thenPriceLine,
    this.badge,
    this.savingsLabel,
  });

  final SubscriptionPlanId id;
  final String title;
  final int price;
  final String billingLine;
  final String perUserLine;
  final String thenPriceLine;
  final String? badge;
  final String? savingsLabel;

  String get formattedPrice => thenPriceLine;

  static const monthly = SubscriptionPlan(
    id: SubscriptionPlanId.monthly,
    title: 'Monthly',
    price: 699,
    billingLine: '£6.99 / month for 2 users',
    perUserLine: '£3.50 / user / month',
    thenPriceLine: '£6.99/month',
  );

  static const yearly = SubscriptionPlan(
    id: SubscriptionPlanId.yearly,
    title: 'Yearly',
    price: 2999,
    billingLine: '£29.99 / year for 2 users',
    perUserLine: '£1.25 / user / month',
    thenPriceLine: '£29.99/year',
    badge: 'Best value',
    savingsLabel: 'Save 64%',
  );

  static const all = [monthly, yearly];

  static SubscriptionPlan? fromId(SubscriptionPlanId? id) {
    if (id == null) return null;
    return all.firstWhere((p) => p.id == id);
  }
}
