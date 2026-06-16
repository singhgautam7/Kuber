import '../../categories/data/category.dart';
import '../../transactions/data/transaction.dart';

/// A resolved date window with a human-readable [label] (e.g. "3 months").
/// [from] is inclusive, [to] is exclusive.
class DateRange {
  final DateTime from;
  final DateTime to;
  final String label;
  const DateRange({required this.from, required this.to, required this.label});
}

/// An entity (category or transaction name) matched out of a query. Used by the
/// frequency and last-transaction handlers to scope their search.
class EntityMatch {
  /// Display label: the category name, or the matched transaction name.
  final String name;

  /// True when the match is a category, false when it's a transaction name.
  final bool isCategory;

  /// Set when [isCategory] is true.
  final int? categoryId;

  /// Lowercased keyword used to match transaction names (when !isCategory).
  final String? nameKeyword;

  /// True when the query matched both a category and a transaction name, so the
  /// category was preferred. Callers surface a "(matched category: …)" note.
  final bool ambiguous;

  const EntityMatch({
    required this.name,
    required this.isCategory,
    this.categoryId,
    this.nameKeyword,
    this.ambiguous = false,
  });
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

  /// Matches a category or transaction name named in [lower]. Category names
  /// take precedence (per spec); when a name also matches a transaction the
  /// match is flagged [EntityMatch.ambiguous]. Returns null when nothing in the
  /// user's data is named in the query.
  ///
  /// Matching mirrors the existing category-spend matcher: an entity matches
  /// when its (lowercased) name appears as a substring of the query. The
  /// longest matching name wins so more specific names beat generic ones.
  EntityMatch? matchEntity(
    String lower,
    List<Category> categories,
    List<Transaction> txns,
  ) {
    Category? catMatch;
    for (final c in categories) {
      final name = c.name.trim().toLowerCase();
      if (name.isEmpty || !lower.contains(name)) continue;
      if (catMatch == null || name.length > catMatch.name.trim().length) {
        catMatch = c;
      }
    }

    String? nameMatch;
    for (final t in txns) {
      final name = t.name.trim().toLowerCase();
      if (name.isEmpty || !lower.contains(name)) continue;
      if (nameMatch == null || name.length > nameMatch.length) {
        nameMatch = name;
      }
    }

    if (catMatch != null) {
      return EntityMatch(
        name: catMatch.name,
        isCategory: true,
        categoryId: catMatch.id,
        ambiguous: nameMatch != null,
      );
    }
    if (nameMatch != null) {
      // Use the transaction's original-cased name for display.
      final display = txns
          .firstWhere((t) => t.name.trim().toLowerCase() == nameMatch)
          .name
          .trim();
      return EntityMatch(
        name: display,
        isCategory: false,
        nameKeyword: nameMatch,
      );
    }
    return null;
  }

  /// Best-effort extraction of the entity the user named, for the "no match"
  /// message when [matchEntity] finds nothing in their data. Operates on the
  /// raw (original-cased) query so the echoed name keeps the user's casing.
  /// Only fires on explicit cues (spend/buy/order/pay, "transactions in X",
  /// "last X transaction") so generic count queries fall through to null.
  String? extractEntityPhrase(String raw) {
    var s = raw.replaceAll(RegExp(r'[?!.]+$'), '').trim();
    // Strip trailing/embedded time phrases so they don't leak into the name.
    s = s.replaceAll(
      RegExp(
        r'\b(this month|last month|this week|last week|this year|today|yesterday)\b',
        caseSensitive: false,
      ),
      ' ',
    );
    s = s.replaceAll(
      RegExp(
        r'\b(?:in|over|for)?\s*(?:the\s+)?(?:past|last)\s+'
        r'(?:\d+|a|an|one|two|three|four|five|six|seven|eight|nine|ten)\s+'
        r'(?:day|days|week|weeks|month|months|year|years)\b',
        caseSensitive: false,
      ),
      ' ',
    );
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    final patterns = <RegExp>[
      RegExp(r'order(?:ed)?\s+from\s+(.+)$', caseSensitive: false),
      RegExp(
        r'(?:spent|spend|paid|pay|bought|buy|purchased|purchase)\s+'
        r'(?:on\s+|for\s+|from\s+)?(.+)$',
        caseSensitive: false,
      ),
      RegExp(
        r'transactions?\s+(?:in|on|for|from)\s+(.+)$',
        caseSensitive: false,
      ),
      RegExp(r'frequency\s+of\s+(.+)$', caseSensitive: false),
      RegExp(
        r'(?:in|on|for|from)\s+(.+?)\s+transactions?$',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:last|recent)\s+(.+?)\s+'
        r'(?:transaction|transactions|expense|payment|purchase|order|bill)\b',
        caseSensitive: false,
      ),
    ];

    for (final p in patterns) {
      final m = p.firstMatch(s);
      if (m == null) continue;
      var phrase = m.group(1)!.trim();
      phrase = phrase.replaceAll(
        RegExp(r'^(?:my|the|a|an)\s+', caseSensitive: false),
        '',
      );
      phrase = phrase
          .replaceAll(
            RegExp(r'\s+transactions?$', caseSensitive: false),
            '',
          )
          .trim();
      if (phrase.isNotEmpty) return phrase;
    }
    return null;
  }
}
