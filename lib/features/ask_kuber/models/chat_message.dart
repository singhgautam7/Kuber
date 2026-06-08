import 'chip_action.dart';
import 'thinking_info.dart';
import 'viz_payload.dart';

/// In-memory chat message held by the screen. [text] is mutable so the
/// typewriter can grow it in place during streaming. [storedId] is the Isar row
/// id once the message has been persisted, so the row can be finalized after
/// streaming completes.
class ChatMessage {
  String text;
  final bool isUser;
  final DateTime time;
  final ThinkingInfo? thinking;
  final VizPayload? vizPayload;
  final List<ChipAction> followUps;
  int? storedId;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.thinking,
    this.vizPayload,
    this.followUps = const [],
    this.storedId,
  });
}
