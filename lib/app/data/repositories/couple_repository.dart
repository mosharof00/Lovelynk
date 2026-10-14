import 'package:intl/intl.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/supabase/supabase_endpoints.dart';
import '../../core/network/supabase/supabase_service.dart';
import '../models/couple_models/pairing_invite.dart';
import '../models/user_models/session_bootstrap.dart';

abstract class ICoupleRepository {
  Future<PairingInvite?> getMyInvite();

  /// Returns my open invite (updating nickname / date) or a new 24h code.
  Future<PairingInvite> createInvite({
    String? partnerNickname,
    DateTime? togetherSince,
  });

  Future<void> cancelInvite();

  /// Pairs with the code's owner. Returns the updated session.
  Future<SessionBootstrap> acceptInvite({
    required String code,
    String? partnerNickname,
    DateTime? togetherSince,
  });

  /// Disconnects from the partner. Returns the updated session.
  Future<SessionBootstrap> leaveCouple();

  /// Null leaves a date unchanged; use the clear flags to remove one.
  /// [nextVisit] is a calendar day (local midnight is sent).
  Future<SessionBootstrap> updateCouple({
    DateTime? togetherSince,
    DateTime? nextVisit,
    bool clearTogetherSince = false,
    bool clearNextVisit = false,
  });

  /// The name I see for my partner; empty clears it.
  Future<SessionBootstrap> updatePartnerNickname(String? nickname);
}

class CoupleRepository implements ICoupleRepository {
  final SupabaseService _supabase;

  CoupleRepository(this._supabase);

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  String? _date(DateTime? value) =>
      value == null ? null : _dateFormat.format(value);

  String? _text(String? value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : v;
  }

  @override
  Future<PairingInvite?> getMyInvite() {
    return _supabase.rpc(
      SupabaseRpc.getMyInvite,
      mapper: (dynamic data) => data == null
          ? null
          : PairingInvite.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<PairingInvite> createInvite({
    String? partnerNickname,
    DateTime? togetherSince,
  }) {
    return _supabase.rpc(
      SupabaseRpc.createInvite,
      params: {
        'p_partner_nickname': _text(partnerNickname),
        'p_together_since': _date(togetherSince),
      },
      mapper: (dynamic data) =>
          PairingInvite.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<void> cancelInvite() {
    return _supabase.rpc(SupabaseRpc.cancelInvite, mapper: (_) {});
  }

  @override
  Future<SessionBootstrap> acceptInvite({
    required String code,
    String? partnerNickname,
    DateTime? togetherSince,
  }) {
    return _supabase.rpc(
      SupabaseRpc.acceptInvite,
      params: {
        'p_code': code.trim(),
        'p_partner_nickname': _text(partnerNickname),
        'p_together_since': _date(togetherSince),
      },
      mapper: (dynamic data) {
        final json = Map<String, dynamic>.from(data as Map);
        // Wrong / own / taken codes come back as data so the server's
        // rate-limit counter is kept (see pairing_rpcs migration).
        final error = json['error'];
        if (error is Map) {
          throw ApiException(
            error['message'] as String? ?? 'Could not connect.',
            code: error['code'] as String?,
          );
        }
        return SessionBootstrap.fromJson(json);
      },
    );
  }

  @override
  Future<SessionBootstrap> leaveCouple() {
    return _supabase.rpc(SupabaseRpc.leaveCouple, mapper: _bootstrap);
  }

  @override
  Future<SessionBootstrap> updateCouple({
    DateTime? togetherSince,
    DateTime? nextVisit,
    bool clearTogetherSince = false,
    bool clearNextVisit = false,
  }) {
    final visitDay = nextVisit == null
        ? null
        : DateTime(nextVisit.year, nextVisit.month, nextVisit.day);
    return _supabase.rpc(
      SupabaseRpc.updateCouple,
      params: {
        'p_together_since': _date(togetherSince),
        'p_next_visit_at': visitDay?.toUtc().toIso8601String(),
        'p_clear_together_since': clearTogetherSince,
        'p_clear_next_visit': clearNextVisit,
      },
      mapper: _bootstrap,
    );
  }

  @override
  Future<SessionBootstrap> updatePartnerNickname(String? nickname) {
    return _supabase.rpc(
      SupabaseRpc.updatePartnerNickname,
      params: {'p_nickname': _text(nickname)},
      mapper: _bootstrap,
    );
  }

  static SessionBootstrap _bootstrap(dynamic data) =>
      SessionBootstrap.fromJson(Map<String, dynamic>.from(data as Map));
}
