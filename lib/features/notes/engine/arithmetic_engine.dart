/// Arithmetic for Kuber Notes. Two modes, decided per line:
///
/// Mode A — inline expression (the `=` inline mode): when a line has a valid
/// math expression to the LEFT of `=` (operators + numbers, BODMAS), evaluate
/// it and insert the result after `=`. Inline expression WINS over column sum.
///
/// Mode B — scoped column sum: a line that is only trigger tokens
/// (`total` / `sum` / `difference` / `=`, or a global phrase `all sum` /
/// `total of all` / `all total`) sums the numbers on the lines above it.
/// Scoped sums from the previous trigger; global sums the whole note.
/// `difference` subtracts subsequent numbers from the first.
library;

import 'expression_evaluator.dart';
import 'number_parser.dart';

class ArithmeticTrigger {
  /// Offset of the first character of the trigger's line.
  final int lineStart;

  /// Exclusive end offset of the line (before the trailing newline).
  final int lineEnd;

  /// Offsets of the trigger word/`=`; the result chip is inserted at
  /// [triggerEnd].
  final int triggerStart;
  final int triggerEnd;

  final String word;
  final bool isGlobal;
  final bool isDifference;

  /// True for Mode A (inline expression). [inlineValue] is then non-null.
  final bool isInline;
  final double? inlineValue;

  const ArithmeticTrigger({
    required this.lineStart,
    required this.lineEnd,
    required this.triggerStart,
    required this.triggerEnd,
    required this.word,
    required this.isGlobal,
    required this.isDifference,
    this.isInline = false,
    this.inlineValue,
  });
}

class ArithmeticResolution {
  final ArithmeticTrigger trigger;

  /// Computed value.
  final double value;

  const ArithmeticResolution({required this.trigger, required this.value});
}

class ArithmeticEngine {
  const ArithmeticEngine();

  static const _globalPhrases = ['all sum', 'total of all', 'all total'];
  static const _scopedTokens = {'total', 'sum', 'difference', '='};

  static const _evaluator = ExpressionEvaluator();

  /// Scans [plainText] and returns one resolution per trigger line. Inline
  /// lines carry their computed value; column lines with at least one number
  /// in scope compute a sum/difference. [resultSpans] are already-resolved
  /// result chips (excluded from both number scanning and trigger matching).
  List<ArithmeticResolution> resolve(
    String plainText, {
    List<PlainTextRange> resultSpans = const [],
    NumberParser parser = const NumberParser(),
  }) {
    final triggers = findTriggers(plainText, resultSpans: resultSpans);
    if (triggers.isEmpty) return const [];

    final tokens = parser.parse(plainText, excluded: resultSpans);
    final inlineTriggers = triggers.where((t) => t.isInline).toList();
    final columnTriggers = triggers.where((t) => !t.isInline).toList();

    bool onInlineLine(int offset) => inlineTriggers
        .any((t) => offset >= t.lineStart && offset < t.lineEnd);
    bool onColumnLine(int offset) => columnTriggers
        .any((t) => offset >= t.lineStart && offset < t.lineEnd);

    // Countable numbers for column sums:
    //  * every regular number NOT on an inline line (its operands are
    //    consumed by the expression) and NOT on a column-trigger line, PLUS
    //  * each inline line's RESULT, counted as one number at that line.
    // Inline lines do NOT act as column-scope boundaries — they are
    // independent math, not column triggers.
    final valuePoints = <({int offset, double value})>[
      for (final t in tokens)
        if (!onInlineLine(t.startOffset) && !onColumnLine(t.startOffset))
          (offset: t.startOffset, value: t.value),
      for (final t in inlineTriggers)
        (offset: t.lineStart, value: t.inlineValue!),
    ]..sort((a, b) => a.offset.compareTo(b.offset));

    final resolutions = <ArithmeticResolution>[];
    for (final trigger in triggers) {
      // Mode A — value already computed from the inline expression.
      if (trigger.isInline) {
        resolutions.add(
            ArithmeticResolution(trigger: trigger, value: trigger.inlineValue!));
        continue;
      }

      // Mode B — scoped / global column sum. Scope runs from the previous
      // COLUMN trigger (inline triggers are ignored as boundaries).
      final idx = columnTriggers.indexOf(trigger);
      final scopeStart = idx <= 0 ? 0 : columnTriggers[idx - 1].lineEnd;
      final scoped = valuePoints.where((p) {
        if (trigger.isGlobal) return true;
        return p.offset >= scopeStart && p.offset < trigger.lineStart;
      }).toList();

      if (scoped.isEmpty) continue;

      double value;
      if (trigger.isDifference) {
        value = scoped.first.value;
        for (final p in scoped.skip(1)) {
          value -= p.value;
        }
      } else {
        value = scoped.fold(0.0, (s, p) => s + p.value);
      }
      resolutions.add(ArithmeticResolution(trigger: trigger, value: value));
    }
    return resolutions;
  }

  List<ArithmeticTrigger> findTriggers(
    String plainText, {
    List<PlainTextRange> resultSpans = const [],
  }) {
    final triggers = <ArithmeticTrigger>[];
    var lineStart = 0;

    while (lineStart <= plainText.length) {
      var lineEnd = plainText.indexOf('\n', lineStart);
      final isLast = lineEnd == -1;
      if (isLast) lineEnd = plainText.length;

      final trigger = _matchLine(plainText, lineStart, lineEnd, resultSpans);
      if (trigger != null) triggers.add(trigger);

      if (isLast) break;
      lineStart = lineEnd + 1;
    }
    return triggers;
  }

  ArithmeticTrigger? _matchLine(
    String text,
    int lineStart,
    int lineEnd,
    List<PlainTextRange> resultSpans,
  ) {
    // Rebuild the line without result-chip characters, keeping the original
    // offset of every retained character.
    final buf = StringBuffer();
    final offsets = <int>[];
    for (var i = lineStart; i < lineEnd; i++) {
      if (resultSpans.any((r) => r.contains(i))) continue;
      buf.write(text[i]);
      offsets.add(i);
    }
    final visible = buf.toString();
    if (visible.trim().isEmpty) return null;

    // Mode A — inline expression takes precedence.
    final inline = _tryInline(visible, offsets, lineStart, lineEnd);
    if (inline != null) return inline;

    // Mode B — column trigger: the line is only trigger tokens.
    return _tryColumn(visible, offsets, lineStart, lineEnd);
  }

  ArithmeticTrigger? _tryInline(
    String visible,
    List<int> offsets,
    int lineStart,
    int lineEnd,
  ) {
    final eqIndex = visible.lastIndexOf('=');
    if (eqIndex <= 0) return null;
    final left = visible.substring(0, eqIndex);

    // Take the maximal suffix of `left` made only of expression characters,
    // stopping at any word letter (so "Eggs", "Discount" prefixes are cut).
    var start = left.length;
    while (start > 0) {
      final c = left[start - 1];
      if (_isExprChar(c)) {
        start--;
      } else {
        break;
      }
    }
    final exprStr = left.substring(start).trim();
    if (exprStr.isEmpty) return null;
    if (!_hasBinaryOperator(exprStr)) return null;
    if (!exprStr.contains(RegExp(r'\d'))) return null;

    final value = _evaluator.evaluate(exprStr);
    if (value == null) return null;

    final eqOffset = offsets[eqIndex];
    return ArithmeticTrigger(
      lineStart: lineStart,
      lineEnd: lineEnd,
      triggerStart: offsets[start.clamp(0, offsets.length - 1)],
      triggerEnd: eqOffset + 1,
      word: '=',
      isGlobal: false,
      isDifference: false,
      isInline: true,
      inlineValue: value,
    );
  }

  ArithmeticTrigger? _tryColumn(
    String visible,
    List<int> offsets,
    int lineStart,
    int lineEnd,
  ) {
    final trimmed = visible.trim().toLowerCase();
    final tokens =
        trimmed.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return null;

    final isGlobal = _globalPhrases.contains(trimmed);
    final isScoped = tokens.every(_scopedTokens.contains);
    if (!isGlobal && !isScoped) return null;

    // Insert the result after the last non-space character of the line.
    var lastVisible = visible.length - 1;
    while (lastVisible > 0 && visible[lastVisible] == ' ') {
      lastVisible--;
    }
    final firstVisible = visible.length - visible.trimLeft().length;

    return ArithmeticTrigger(
      lineStart: lineStart,
      lineEnd: lineEnd,
      triggerStart: offsets[firstVisible.clamp(0, offsets.length - 1)],
      triggerEnd: offsets[lastVisible] + 1,
      word: trimmed,
      isGlobal: isGlobal,
      isDifference: !isGlobal && tokens.contains('difference'),
    );
  }

  static bool _isExprChar(String c) {
    if (c == ' ' || c == '.' || c == ',' || c == '₹') return true;
    if (c == '+' || c == '-' || c == '*' || c == '/' || c == '(' || c == ')') {
      return true;
    }
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39; // digit
  }

  /// True when [expr] contains an operator that implies computation: any of
  /// `+ * / (`, or a `-` used as a binary operator (a digit/`)` precedes it,
  /// ignoring spaces) — so a bare negative number like `-30` is NOT inline.
  static bool _hasBinaryOperator(String expr) {
    for (var i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (c == '+' || c == '*' || c == '/' || c == '(') return true;
      if (c == '-') {
        var j = i - 1;
        while (j >= 0 && expr[j] == ' ') {
          j--;
        }
        if (j >= 0) {
          final p = expr[j];
          final isDigit = p.codeUnitAt(0) >= 0x30 && p.codeUnitAt(0) <= 0x39;
          if (isDigit || p == ')') return true;
        }
      }
    }
    return false;
  }
}
