/// A resolved date window with a human-readable [label] (e.g. "3 months").
/// [from] is inclusive, [to] is exclusive.
class DateRange {
  final DateTime from;
  final DateTime to;
  final String label;
  const DateRange({required this.from, required this.to, required this.label});
}

/// Pulls structured parameters (date windows, time context) out of a raw query
/// string. Ported verbatim from the original monolithic `_processQuery` so the
/// answers it feeds remain byte-for-byte identical.
class ParameterExtractor {
  const ParameterExtractor();

  static const _wordNums = {
    'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
    'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
  };

  /// Parses "past two weeks", "last 3 months", "last year", etc.
  /// Returns null when the query has no relative-range phrase.
  DateRange? customRange(String lower) {
    final match = RegExp(
      r'(?:past|last)\s+(\d+|a|an|one|two|three|four|five|six|seven|eight|nine|ten)'
      r'\s+(day|days|week|weeks|month|months|year|years)',
    ).firstMatch(lower);
    if (match == null) return null;

    final numStr = match.group(1)!;
    final n = int.tryParse(numStr) ?? _wordNums[numStr] ?? 1;
    final unit = match.group(2)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final to = today.add(const Duration(days: 1));

    DateTime from;
    String label;
    if (unit.startsWith('day')) {
      from = today.subtract(Duration(days: n - 1));
      label = n == 1 ? 'day' : '$n days';
    } else if (unit.startsWith('week')) {
      from = today.subtract(Duration(days: n * 7));
      label = n == 1 ? 'week' : '$n weeks';
    } else if (unit.startsWith('month')) {
      int m = now.month - n;
      int y = now.year;
      while (m <= 0) {
        m += 12;
        y--;
      }
      from = DateTime(y, m, now.day);
      label = n == 1 ? 'month' : '$n months';
    } else {
      from = DateTime(now.year - n, now.month, now.day);
      label = n == 1 ? 'year' : '$n years';
    }
    return DateRange(from: from, to: to, label: label);
  }

  /// True when the query names any explicit time window (today / this week /
  /// last month / "past N units" / …). Used to decide all-time vs scoped.
  bool hasExplicitTimeContext(String lower) =>
      lower.contains('today') ||
      lower.contains('this week') ||
      lower.contains('this month') ||
      lower.contains('last month') ||
      lower.contains('last week') ||
      lower.contains('this year') ||
      RegExp(r'(?:past|last)\s+\d+').hasMatch(lower) ||
      RegExp(r'(?:past|last)\s+(?:a|an|one|two|three|four|five|six|seven|eight|nine|ten)\s+\w+')
          .hasMatch(lower);
}
