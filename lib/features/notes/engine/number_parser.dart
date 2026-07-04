/// Pure-Dart numeric token extraction for Kuber Notes.
///
/// Works on the plain text of a Quill document. Handles plain integers
/// (`500`), decimals (`450.50`), signed values (`-500`, `+1200`), currency
/// prefixed values (`₹500`, `₹1,200`) and Indian comma grouping (`1,00,000`).
library;

/// A half-open `[start, end)` character range in the source text.
class PlainTextRange {
  final int start;
  final int end;

  const PlainTextRange(this.start, this.end);

  bool contains(int offset) => offset >= start && offset < end;

  bool overlaps(int otherStart, int otherEnd) =>
      otherStart < end && otherEnd > start;
}

class NumberToken {
  /// Signed numeric value (`-30` parses to -30.0).
  final double value;

  /// Offset of the first character of the token (sign or ₹ included).
  final int startOffset;

  /// Exclusive end offset.
  final int endOffset;

  /// True when the token carried an explicit `+` or `-` sign.
  final bool isSigned;

  /// True when the token carried a `₹` prefix.
  final bool hasCurrency;

  const NumberToken({
    required this.value,
    required this.startOffset,
    required this.endOffset,
    required this.isSigned,
    required this.hasCurrency,
  });

  bool get isNegative => value < 0;

  int get length => endOffset - startOffset;
}

class NumberParser {
  const NumberParser();

  /// `sign? ₹? digits[,digits...][.decimals]` — boundaries are validated
  /// manually so `v2`, `3.4.5` or `12th` never produce tokens.
  static final RegExp _pattern = RegExp(
    r'([+\-]?)(₹?)(\d{1,3}(?:,\d{2,3})+(?:\.\d+)?|\d+(?:\.\d+)?)',
  );

  static bool _isWordChar(String c) =>
      RegExp(r'[A-Za-z0-9_]').hasMatch(c) || c == '.' || c == ',' || c == '₹';

  /// Extracts all numeric tokens from [text]. Ranges listed in [excluded]
  /// (e.g. resolved arithmetic results) never produce tokens.
  List<NumberToken> parse(String text, {List<PlainTextRange> excluded = const []}) {
    final tokens = <NumberToken>[];

    for (final m in _pattern.allMatches(text)) {
      final sign = m.group(1)!;
      final currency = m.group(2)!;
      final digits = m.group(3)!;

      // Reject when glued to a word/number on the left …
      if (m.start > 0 && _isWordChar(text[m.start - 1])) continue;
      // … or on the right (`3.4.5`, `12th`).
      if (m.end < text.length && _isWordChar(text[m.end])) continue;

      // A sign only counts when attached to the number, i.e. "-30" not "- 30".
      // The regex already guarantees adjacency; nothing extra needed here.

      if (excluded.any((r) => r.overlaps(m.start, m.end))) continue;

      final raw = digits.replaceAll(',', '');
      final magnitude = double.tryParse(raw);
      if (magnitude == null) continue;

      tokens.add(NumberToken(
        value: sign == '-' ? -magnitude : magnitude,
        startOffset: m.start,
        endOffset: m.end,
        isSigned: sign.isNotEmpty,
        hasCurrency: currency.isNotEmpty,
      ));
    }
    return tokens;
  }
}
