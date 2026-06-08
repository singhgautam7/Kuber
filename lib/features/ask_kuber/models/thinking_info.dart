/// Transparency metadata attached to a Kuber answer: which date window was
/// applied and which data sources were scanned to produce it. Surfaced behind
/// the "SHOW THINKING" expander in the message bubble.
class ThinkingInfo {
  final String dateFilter;
  final List<String> scanned;

  const ThinkingInfo({required this.dateFilter, required this.scanned});

  Map<String, dynamic> toJson() => {
    'dateFilter': dateFilter,
    'scanned': scanned,
  };

  factory ThinkingInfo.fromJson(Map<String, dynamic> json) => ThinkingInfo(
    dateFilter: json['dateFilter'] as String? ?? '',
    scanned: (json['scanned'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );
}
