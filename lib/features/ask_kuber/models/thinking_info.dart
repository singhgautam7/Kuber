/// One step in Kuber's reasoning trace. [text] may contain `**bold**` markers
/// around the tokens to emphasize (numbers, category names, time ranges). The
/// renderer parses the markers; no separate emphasis list is needed.
class ThinkingStep {
  final String text;
  const ThinkingStep(this.text);

  factory ThinkingStep.fromJson(String raw) => ThinkingStep(raw);
  String toJson() => text;
}

/// Transparency metadata attached to a Kuber answer: which date window was
/// applied, which data sources were scanned, and the ordered reasoning [steps]
/// shown in the expanded "thinking" panel.
///
/// [steps] is a new field (added without mutating the existing ones), so chat
/// history persisted before this change deserializes with an empty list and the
/// panel falls back to a date-range / scanned summary at render time.
class ThinkingInfo {
  final String dateFilter;
  final List<String> scanned;
  final List<ThinkingStep> steps;

  const ThinkingInfo({
    required this.dateFilter,
    required this.scanned,
    this.steps = const [],
  });

  Map<String, dynamic> toJson() => {
    'dateFilter': dateFilter,
    'scanned': scanned,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory ThinkingInfo.fromJson(Map<String, dynamic> json) => ThinkingInfo(
    dateFilter: json['dateFilter'] as String? ?? '',
    scanned: (json['scanned'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
    steps: (json['steps'] as List<dynamic>? ?? const [])
        .map((e) => ThinkingStep.fromJson(e.toString()))
        .toList(),
  );
}
