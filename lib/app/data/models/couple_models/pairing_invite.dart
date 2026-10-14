/// My open invite code (`create_invite` / `get_my_invite`).
class PairingInvite {
  const PairingInvite({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;

  bool get isExpired => !expiresAt.isAfter(DateTime.now());

  Duration get remaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// "Expires in 23h 59m" / "Expires in 12m" / "Expired".
  String get expiresLabel {
    if (isExpired) return 'Code expired';
    final r = remaining;
    if (r.inHours >= 1) {
      return 'Expires in ${r.inHours}h ${r.inMinutes.remainder(60)}m';
    }
    return 'Expires in ${r.inMinutes < 1 ? 1 : r.inMinutes}m';
  }

  factory PairingInvite.fromJson(Map<String, dynamic> json) {
    return PairingInvite(
      code: json['code'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
    );
  }
}
