import '../models/thinking_info.dart';

/// Builders for the reasoning steps shown in the expanded thinking panel.
/// Tokens wrapped in `**...**` render bold. Keeping these in one place keeps
/// step phrasing consistent across handlers.

/// Step 1 (universal): detected intent + parsed time range.
ThinkingStep intentStep(String intent, String range) =>
    ThinkingStep('Detected intent: **$intent**. Parsed time range: **$range**.');

/// Step 2 (universal): scanned sources. Drops the grouping clause when [groups]
/// is null.
ThinkingStep scannedStep(
  int count,
  String itemType, {
  int? groups,
  String? groupType,
  String? dimension,
}) {
  final items = '**$count ${_plural(count, itemType)}**';
  if (groups != null && groupType != null) {
    return ThinkingStep(
      'Scanned $items across **$groups ${_plural(groups, groupType)}**, '
      'grouped by ${dimension ?? groupType}.',
    );
  }
  return ThinkingStep('Scanned $items.');
}

/// Step 3 (handler-specific): result reasoning. [text] uses `**bold**` markers.
ThinkingStep resultStep(String text) => ThinkingStep(text);

/// Universal closing step when a handler can't form a richer result line.
const ThinkingStep closingStep =
    ThinkingStep('Computed result from the scanned data.');

String _plural(int n, String word) {
  if (n == 1) {
    if (word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
    if (word.endsWith('s')) return word.substring(0, word.length - 1);
  }
  return word;
}
