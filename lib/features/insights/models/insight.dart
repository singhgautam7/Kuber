enum InsightType {
  budget,
  trend,
  behavior,
}

enum InsightPriority {
  high,
  medium,
  low,
}

class Insight {
  final String id;
  final String message;
  final InsightType type;
  final InsightPriority priority;

  Insight({
    required this.id,
    required this.message,
    required this.type,
    required this.priority,
  });
}
