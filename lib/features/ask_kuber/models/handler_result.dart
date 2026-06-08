import 'chip_action.dart';
import 'thinking_info.dart';
import 'viz_payload.dart';

/// The product of a [QueryHandler]: the answer text plus optional thinking
/// metadata, an inline visualization, and follow-up chips.
class HandlerResult {
  final String text;
  final ThinkingInfo? thinking;
  final VizPayload? vizPayload;
  final List<ChipAction> followUps;

  const HandlerResult({
    required this.text,
    this.thinking,
    this.vizPayload,
    this.followUps = const [],
  });
}
