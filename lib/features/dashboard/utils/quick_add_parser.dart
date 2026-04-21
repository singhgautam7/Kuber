class QuickAddResult {
  final double? amount;
  final String? category;
  final String? accountHint;

  const QuickAddResult({this.amount, this.category, this.accountHint});
}

QuickAddResult parseQuickAdd(String input) {
  // Strip currency symbols and common prefixes
  var cleaned = input
      .trim()
      .replaceAll('₹', '')
      .replaceAll(RegExp(r'[Rr][Ss]\.?\s*'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  cleaned = cleaned.replaceFirst(RegExp(r'^spent\s+', caseSensitive: false), '');
  cleaned = cleaned.replaceFirst(RegExp(r'^(add|create|log|record)\s+', caseSensitive: false), '');

  // Extract first number
  final numMatch = RegExp(r'\d+(\.\d+)?').firstMatch(cleaned);
  final amount = numMatch != null ? double.tryParse(numMatch.group(0)!) : null;
  final afterNum =
      numMatch != null ? cleaned.substring(numMatch.end).trim() : cleaned;
  final lowerAfter = afterNum.toLowerCase();

  // Locate ' on ' and ' from ' markers
  final onIdx = lowerAfter.indexOf(' on ');
  final fromIdx = lowerAfter.indexOf(' from ');

  String? category;
  String? accountHint;

  if (onIdx != -1) {
    final catStart = onIdx + 4;
    final catEnd = (fromIdx != -1 && fromIdx > onIdx) ? fromIdx : afterNum.length;
    category = afterNum.substring(catStart, catEnd).trim();
  } else if (lowerAfter.startsWith('on ')) {
    final catEnd = fromIdx != -1 ? fromIdx : afterNum.length;
    category = afterNum.substring(3, catEnd).trim();
  } else if (afterNum.isNotEmpty) {
    final catEnd = fromIdx != -1 ? fromIdx : afterNum.length;
    category = afterNum.substring(0, catEnd).trim();
  }

  if (fromIdx != -1) {
    accountHint = afterNum.substring(fromIdx + 6).trim();
  }

  if (category != null) {
    category = category
        .replaceFirst(RegExp(r'^(on|in|for|a|an|the|at|to)\s+', caseSensitive: false), '')
        .trim();
    if (category.isEmpty) category = null;
  }
  if (accountHint != null && accountHint.isEmpty) accountHint = null;

  return QuickAddResult(amount: amount, category: category, accountHint: accountHint);
}
