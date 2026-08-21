/// One batched reaction in the Heartbeat / Kiss / Emoji activity feed.
class ReactionActivity {
  const ReactionActivity({
    required this.senderName,
    required this.isFromMe,
    required this.count,
    required this.at,
  });

  final String senderName;
  final bool isFromMe;
  final int count;
  final DateTime at;
}
