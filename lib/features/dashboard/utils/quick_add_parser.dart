import '../../categories/data/category.dart';

import '../../../shared/utils/category_fuzzy_matcher.dart';

class QuickAddParsedItem {
  final String originalSegment;
  final double? amount;
  final String type; // 'expense' | 'income'
  final String? categoryCandidate;
  final CategoryMatchResult matchResult;
  final String? accountHint;
  final String? note;

  const QuickAddParsedItem({
    required this.originalSegment,
    required this.amount,
    this.type = 'expense',
    this.categoryCandidate,
    required this.matchResult,
    this.accountHint,
    this.note,
  });

  QuickAddParsedItem copyWith({
    String? originalSegment,
    double? amount,
    String? type,
    String? categoryCandidate,
    CategoryMatchResult? matchResult,
    String? accountHint,
    String? note,
  }) {
    return QuickAddParsedItem(
      originalSegment: originalSegment ?? this.originalSegment,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryCandidate: categoryCandidate ?? this.categoryCandidate,
      matchResult: matchResult ?? this.matchResult,
      accountHint: accountHint ?? this.accountHint,
      note: note ?? this.note,
    );
  }
}

class QuickAddResult {
  final double? amount;
  final String? category;
  final String? accountHint;

  const QuickAddResult({this.amount, this.category, this.accountHint});
}

/// Legacy single line parser wrapper for backward compatibility.
QuickAddResult parseQuickAdd(String input) {
  final item = parseQuickAddSegment(input, const []);
  return QuickAddResult(
    amount: item.amount,
    category: item.categoryCandidate,
    accountHint: item.accountHint,
  );
}

/// Splits multi-transaction input on newlines, ' and ', ',', '+', 'then'.
List<String> splitQuickAddInput(String input) {
  final rawLines = input.split(RegExp(r'[\r\n]+'));
  final segments = <String>[];

  for (final line in rawLines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    // Split by ' and ', ', ', ' then ', '+' (when between words/spaces or separate expenses)
    final parts = trimmed.split(RegExp(
      r'(?:\s+and\s+|\s*,\s*|\s+then\s+|\s*\+\s*)',
      caseSensitive: false,
    ));

    for (final part in parts) {
      final p = part.trim();
      if (p.isNotEmpty) {
        segments.add(p);
      }
    }
  }

  return segments.isEmpty ? [input.trim()] : segments;
}

/// Parses a single segment into a [QuickAddParsedItem].
QuickAddParsedItem parseQuickAddSegment(String input, List<Category> availableCategories) {
  var cleaned = input
      .trim()
      .replaceAll('₹', '')
      .replaceAll(RegExp(r'[Rr][Ss]\.?\s*'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool isIncome = false;
  if (cleaned.startsWith('+') ||
      RegExp(r'^(received|income|salary|refund|got)\s+', caseSensitive: false).hasMatch(cleaned) ||
      RegExp(r'\b(salary|income|freelance|cashback)\b', caseSensitive: false).hasMatch(cleaned)) {
    isIncome = true;
  }

  cleaned = cleaned
      .replaceFirst(RegExp(r'^\+\s*'), '')
      .replaceFirst(RegExp(r'^(spent|spent on|spent in|paid|add|create|log|record|received|got)\s+', caseSensitive: false), '')
      .trim();

  // Extract first number
  final numMatch = RegExp(r'\d+(\.\d+)?').firstMatch(cleaned);
  final amount = numMatch != null ? double.tryParse(numMatch.group(0)!) : null;

  final afterNum = numMatch != null ? cleaned.substring(numMatch.end).trim() : cleaned;
  final lowerAfter = afterNum.toLowerCase();

  final onIdx = lowerAfter.indexOf(' on ');
  final inIdx = lowerAfter.indexOf(' in ');
  final forIdx = lowerAfter.indexOf(' for ');
  final fromIdx = lowerAfter.indexOf(' from ');

  String? categoryCandidate;
  String? accountHint;

  int catStart = -1;
  int firstPrep = -1;

  final prepIndices = [
    if (onIdx != -1) onIdx,
    if (inIdx != -1) inIdx,
    if (forIdx != -1) forIdx,
  ]..sort();

  if (prepIndices.isNotEmpty) {
    firstPrep = prepIndices.first;
    catStart = firstPrep + 4; // length of ' on ', ' in ', ' for '
  } else if (lowerAfter.startsWith('on ')) {
    catStart = 3;
  } else if (lowerAfter.startsWith('in ')) {
    catStart = 3;
  } else if (lowerAfter.startsWith('for ')) {
    catStart = 4;
  } else if (afterNum.isNotEmpty) {
    catStart = 0;
  }

  if (catStart != -1) {
    final catEnd = (fromIdx != -1 && fromIdx > catStart) ? fromIdx : afterNum.length;
    if (catEnd > catStart) {
      categoryCandidate = afterNum.substring(catStart, catEnd).trim();
    }
  }

  if (fromIdx != -1) {
    accountHint = afterNum.substring(fromIdx + 6).trim();
  }

  if (categoryCandidate != null) {
    categoryCandidate = categoryCandidate
        .replaceFirst(RegExp(r'^(on|in|for|a|an|the|at|to)\s+', caseSensitive: false), '')
        .trim();
    if (categoryCandidate.isEmpty) categoryCandidate = null;
  }

  if (accountHint != null && accountHint.isEmpty) accountHint = null;

  final matchResult = categoryCandidate != null && categoryCandidate.isNotEmpty
      ? CategoryFuzzyMatcher.match(categoryCandidate, availableCategories)
      : CategoryMatchResult.noMatch(categoryCandidate ?? '');

  return QuickAddParsedItem(
    originalSegment: input,
    amount: amount,
    type: isIncome ? 'income' : 'expense',
    categoryCandidate: categoryCandidate,
    matchResult: matchResult,
    accountHint: accountHint,
    note: input,
  );
}

/// Parses multi-transaction input text into candidate items.
List<QuickAddParsedItem> parseMultiQuickAdd(String input, List<Category> categories) {
  final segments = splitQuickAddInput(input);
  return segments.map((s) => parseQuickAddSegment(s, categories)).toList();
}
