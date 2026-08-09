// Rule-based, offline Quick Add parser. Turns free text like
// "250 in groceries and 300 movies" or "1200 salary income" into one or many
// [ParsedQuickAddTxn]. No AI / LLM, no I/O — pure string work so it is instant
// and safe to run on the UI isolate. Shared by the Quick Add page (Feature 1)
// and the Ask Kuber transaction preview (Feature 2).

/// One parsed line. [categoryHint] / [accountHint] are raw phrases; resolving
/// them to real entities (via `matchCategory` + the account list) is the
/// caller's job. [amount] is null when the line has no detectable number.
class ParsedQuickAddTxn {
  final double? amount;
  final String? categoryHint;
  final String? accountHint;
  final String type; // 'income' | 'expense'
  final String rawText; // the original segment, for source provenance

  const ParsedQuickAddTxn({
    required this.amount,
    required this.categoryHint,
    required this.accountHint,
    required this.type,
    required this.rawText,
  });

  bool get isParsed => amount != null && amount! > 0;
}

/// Words that flip a line to income. Matched case-insensitively as whole-ish
/// tokens against the raw segment.
const _incomeKeywords = <String>{
  'salary', 'income', 'received', 'earned', 'credited', 'refund', 'refunded',
  'bonus', 'cashback', 'interest', 'dividend', 'stipend', 'payroll',
  'reimbursement', 'reimbursed',
};

/// Leading action verbs stripped before category extraction (they carry no
/// category meaning). Income verbs are stripped too — type is detected first.
final _leadingVerb = RegExp(
  r'^(spent|paid|add|added|create|log|logged|record|recorded|got|received|earned|credited)\s+',
  caseSensitive: false,
);

/// Splits on a newline (one transaction per line) and the connectors "and",
/// ",", "+", "&". " and " needs surrounding whitespace so words like "sandwich"
/// are never split.
final _connector =
    RegExp(r'\r?\n|\s+and\s+|\s*[,+&]\s*', caseSensitive: false);

/// A number, allowing Indian grouping commas and an optional decimal, e.g.
/// "1,200" or "250.50". Commas are stripped before parsing.
final _number = RegExp(r'\d[\d,]*(?:\.\d+)?');

/// Trailing/standalone noise words removed from an extracted category phrase.
final _categoryNoise = RegExp(
  r'\b(income|expense|rupees?|rs|only|please)\b',
  caseSensitive: false,
);

/// Parses [input] into one entry per detected segment. Segments with no number
/// are still returned (with a null amount) so the caller can show a
/// "couldn't read this line" card and exclude it from the count.
List<ParsedQuickAddTxn> parseQuickAddMulti(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return const [];
  // Strip thousands-separator commas (digit,digit) BEFORE splitting so a
  // grouped amount like "1,200" is never mistaken for a segment separator.
  final degrouped =
      trimmed.replaceAllMapped(RegExp(r'(\d),(?=\d)'), (m) => m.group(1)!);
  final segments = degrouped
      .split(_connector)
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (segments.isEmpty) return const [];
  return segments.map(_parseSegment).toList(growable: false);
}

/// Convenience for single-line callers (e.g. the inline home-widget send):
/// the first parsed segment, or an empty unparsed result.
ParsedQuickAddTxn parseQuickAddSingle(String input) {
  final all = parseQuickAddMulti(input);
  if (all.isNotEmpty) return all.first;
  return ParsedQuickAddTxn(
    amount: null,
    categoryHint: null,
    accountHint: null,
    type: 'expense',
    rawText: input.trim(),
  );
}

ParsedQuickAddTxn _parseSegment(String segment) {
  final raw = segment.trim();

  // Currency symbols / prefixes out, whitespace collapsed.
  var cleaned = raw
      .replaceAll('₹', ' ')
      .replaceAll(RegExp(r'\b[Rr][Ss]\.?\s*'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // Detect income from the whole segment BEFORE stripping verbs, so "received"
  // / "earned" still count even though they are stripped next.
  final lowerFull = cleaned.toLowerCase();
  final type =
      _incomeKeywords.any((k) => _containsWord(lowerFull, k)) ? 'income' : 'expense';

  cleaned = cleaned.replaceFirst(_leadingVerb, '').trim();

  // Amount: first number anywhere in the segment.
  final numMatch = _number.firstMatch(cleaned);
  final amount = numMatch == null
      ? null
      : double.tryParse(numMatch.group(0)!.replaceAll(',', ''));
  final afterNum =
      numMatch != null ? cleaned.substring(numMatch.end).trim() : cleaned;
  final lowerAfter = afterNum.toLowerCase();

  // ' on <category>' / ' from <account>' markers, mirroring the original parser.
  final onIdx = lowerAfter.indexOf(' on ');
  final fromIdx = _firstAccountMarker(lowerAfter);

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
    // account phrase begins after the marker word (' from '/' via '/' using ').
    final markerLen = _accountMarkerLengthAt(lowerAfter, fromIdx);
    accountHint = afterNum.substring(fromIdx + markerLen).trim();
  }

  category = _cleanCategory(category);
  if (accountHint != null && accountHint.isEmpty) accountHint = null;

  return ParsedQuickAddTxn(
    amount: amount,
    categoryHint: category,
    accountHint: accountHint,
    type: type,
    rawText: raw,
  );
}

/// Index of the first account marker (' from ' / ' via ' / ' using '), or -1.
int _firstAccountMarker(String lower) {
  var best = -1;
  for (final m in const [' from ', ' via ', ' using ']) {
    final i = lower.indexOf(m);
    if (i != -1 && (best == -1 || i < best)) best = i;
  }
  return best;
}

int _accountMarkerLengthAt(String lower, int idx) {
  for (final m in const [' from ', ' via ', ' using ']) {
    if (lower.startsWith(m, idx)) return m.length;
  }
  return 6; // ' from '
}

String? _cleanCategory(String? category) {
  if (category == null) return null;
  var c = category
      .replaceFirst(
        RegExp(r'^(on|in|for|a|an|the|at|to)\s+', caseSensitive: false),
        '',
      )
      .replaceAll(_categoryNoise, '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return c.isEmpty ? null : c;
}

/// Whole-word-ish containment so "salary" matches but "salaryman" style false
/// positives are avoided; keeps it cheap (no full tokenization).
bool _containsWord(String haystack, String word) {
  final i = haystack.indexOf(word);
  if (i == -1) return false;
  final before = i == 0 ? ' ' : haystack[i - 1];
  final afterIdx = i + word.length;
  final after = afterIdx >= haystack.length ? ' ' : haystack[afterIdx];
  return !_isWordChar(before) && !_isWordChar(after);
}

bool _isWordChar(String ch) => RegExp(r'[a-z0-9]').hasMatch(ch);
