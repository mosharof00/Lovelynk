import '../widget_models/reaction_activity.dart';

/// Interaction totals, recent emojis, and today's activity returned by `get_interaction_summary`.
class InteractionSummary {
  final int heartbeatsFromPartner;
  final int heartbeatsFromMe;
  final int kissesFromPartner;
  final int kissesFromMe;
  final int emojiCountFromPartner;
  final int emojiCountFromMe;
  final List<String> partnerRecentEmojis;
  final List<String> myRecentEmojis;
  final int todayHeartbeatsFromPartner;
  final int todayHeartbeatsFromMe;
  final int todayKissesFromPartner;
  final int todayKissesFromMe;
  final int todayEmojisFromPartner;
  final int todayEmojisFromMe;
  final List<ReactionActivity> todayHeartbeatActivity;
  final List<ReactionActivity> todayKissActivity;
  final List<ReactionActivity> todayEmojiActivity;

  const InteractionSummary({
    this.heartbeatsFromPartner = 0,
    this.heartbeatsFromMe = 0,
    this.kissesFromPartner = 0,
    this.kissesFromMe = 0,
    this.emojiCountFromPartner = 0,
    this.emojiCountFromMe = 0,
    this.partnerRecentEmojis = const [],
    this.myRecentEmojis = const [],
    this.todayHeartbeatsFromPartner = 0,
    this.todayHeartbeatsFromMe = 0,
    this.todayKissesFromPartner = 0,
    this.todayKissesFromMe = 0,
    this.todayEmojisFromPartner = 0,
    this.todayEmojisFromMe = 0,
    this.todayHeartbeatActivity = const [],
    this.todayKissActivity = const [],
    this.todayEmojiActivity = const [],
  });

  factory InteractionSummary.fromJson(Map<String, dynamic> json) {
    List<ReactionActivity> parseActivity(dynamic raw) {
      if (raw is! List) return <ReactionActivity>[];
      return raw
          .map((e) => ReactionActivity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    List<String> parseStrings(dynamic raw) {
      if (raw is! List) return <String>[];
      return raw.map((e) => e.toString()).toList();
    }

    return InteractionSummary(
      heartbeatsFromPartner: (json['heartbeats_from_partner'] as num?)?.toInt() ?? 0,
      heartbeatsFromMe: (json['heartbeats_from_me'] as num?)?.toInt() ?? 0,
      kissesFromPartner: (json['kisses_from_partner'] as num?)?.toInt() ?? 0,
      kissesFromMe: (json['kisses_from_me'] as num?)?.toInt() ?? 0,
      emojiCountFromPartner: (json['emoji_count_from_partner'] as num?)?.toInt() ?? 0,
      emojiCountFromMe: (json['emoji_count_from_me'] as num?)?.toInt() ?? 0,
      partnerRecentEmojis: parseStrings(json['partner_recent_emojis']),
      myRecentEmojis: parseStrings(json['my_recent_emojis']),
      todayHeartbeatsFromPartner:
          (json['today_heartbeats_from_partner'] as num?)?.toInt() ?? 0,
      todayHeartbeatsFromMe: (json['today_heartbeats_from_me'] as num?)?.toInt() ?? 0,
      todayKissesFromPartner: (json['today_kisses_from_partner'] as num?)?.toInt() ?? 0,
      todayKissesFromMe: (json['today_kisses_from_me'] as num?)?.toInt() ?? 0,
      todayEmojisFromPartner: (json['today_emojis_from_partner'] as num?)?.toInt() ?? 0,
      todayEmojisFromMe: (json['today_emojis_from_me'] as num?)?.toInt() ?? 0,
      todayHeartbeatActivity: parseActivity(json['today_heartbeat_activity']),
      todayKissActivity: parseActivity(json['today_kiss_activity']),
      todayEmojiActivity: parseActivity(json['today_emoji_activity']),
    );
  }
}
