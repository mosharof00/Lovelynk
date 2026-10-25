import '../../core/network/supabase/supabase_endpoints.dart';
import '../../core/network/supabase/supabase_service.dart';
import '../models/interaction_models/interaction_feed_item.dart';
import '../models/interaction_models/interaction_summary.dart';

abstract class IInteractionRepository {
  /// Sends heartbeat, kiss, or emoji interaction to the partner.
  Future<Map<String, dynamic>> sendInteraction({
    required String kind,
    int count = 1,
    String? emoji,
  });

  /// Fetches running totals, recent emojis, and today's activity.
  Future<InteractionSummary> getSummary();

  /// Fetches cursor-paginated activity feed for the couple.
  Future<InteractionFeedPage> getFeed({
    String? kind,
    DateTime? before,
    int limit = 30,
  });
}

class InteractionRepository implements IInteractionRepository {
  final SupabaseService _supabase;

  InteractionRepository(this._supabase);

  @override
  Future<Map<String, dynamic>> sendInteraction({
    required String kind,
    int count = 1,
    String? emoji,
  }) {
    return _supabase.rpc<Map<String, dynamic>>(
      SupabaseRpc.sendInteraction,
      params: {
        'p_kind': kind,
        'p_count': count,
        if (emoji != null && emoji.isNotEmpty) 'p_emoji': emoji,
      },
      mapper: (dynamic data) {
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{'success': true};
      },
    );
  }

  @override
  Future<InteractionSummary> getSummary() {
    return _supabase.rpc<InteractionSummary>(
      SupabaseRpc.getInteractionSummary,
      mapper: (dynamic data) {
        if (data is Map) {
          return InteractionSummary.fromJson(Map<String, dynamic>.from(data));
        }
        return const InteractionSummary();
      },
    );
  }

  @override
  Future<InteractionFeedPage> getFeed({
    String? kind,
    DateTime? before,
    int limit = 30,
  }) {
    return _supabase.rpc<InteractionFeedPage>(
      SupabaseRpc.getInteractionFeed,
      params: {
        if (kind != null) 'p_kind': kind,
        if (before != null) 'p_before': before.toUtc().toIso8601String(),
        'p_limit': limit,
      },
      mapper: (dynamic data) {
        if (data is Map) {
          return InteractionFeedPage.fromJson(Map<String, dynamic>.from(data));
        }
        return const InteractionFeedPage(items: [], hasMore: false);
      },
    );
  }
}
