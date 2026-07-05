import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'arithmetic_engine.dart';
import 'number_parser.dart';

/// Inline attribute for a regular highlighted number. Value is `'pos'` or
/// `'neg'`. Serialized into the Delta JSON, so highlights survive reloads.
class NumberHighlightAttribute extends Attribute<String?> {
  const NumberHighlightAttribute(String? value)
      : super(kKey, AttributeScope.inline, value);

  static const kKey = 'kuber-num';
  static const positive = NumberHighlightAttribute('pos');
  static const negative = NumberHighlightAttribute('neg');
  static const unset = NumberHighlightAttribute(null);
}

/// Inline attribute for a resolved arithmetic result chip. Value is the
/// canonical `double.toString()` of the computed amount.
class ArithResultAttribute extends Attribute<String?> {
  const ArithResultAttribute(String? value)
      : super(kKey, AttributeScope.inline, value);

  static const kKey = 'kuber-arith';
  static const unset = ArithResultAttribute(null);
}

class _Span {
  final int start;
  final int length;
  final String value;
  const _Span(this.start, this.length, this.value);

  int get end => start + length;
}

/// Reads the Quill document, highlights numeric tokens, and keeps resolved
/// arithmetic result chips in sync with the numbers above their triggers.
///
/// Call [apply] on a debounce after edits. All mutations set [isApplying] so
/// the caller's change listener can ignore self-inflicted document changes.
class QuillNumberHighlighter {
  QuillNumberHighlighter({required this.formatAmount});

  /// Formats a computed amount into the chip text (e.g. `₹1,00,000`).
  final String Function(double) formatAmount;

  final NumberParser _parser = const NumberParser();
  final ArithmeticEngine _engine = const ArithmeticEngine();

  bool isApplying = false;

  /// Whole numbers render as integers; fractional results to 2 decimals.
  static String _plainNumber(double v) => v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2);

  /// Re-scans [controller]'s document and reconciles highlights + results.
  void apply(QuillController controller) {
    if (isApplying) return;
    isApplying = true;
    try {
      _reconcileHighlights(controller);
      _reconcileResults(controller);
    } finally {
      isApplying = false;
    }
  }

  // ── Span collection ─────────────────────────────────────────────────────

  List<_Span> _spansWithKey(Document document, String key) {
    final spans = <_Span>[];
    for (final node in document.root.children) {
      _collectFromNode(node, key, spans);
    }
    return spans;
  }

  void _collectFromNode(Node node, String key, List<_Span> out) {
    if (node is Line) {
      for (final leaf in node.children) {
        final attr = leaf.style.attributes[key];
        if (attr != null && attr.value != null) {
          out.add(_Span(leaf.documentOffset, leaf.length, '${attr.value}'));
        }
      }
    } else if (node is Block) {
      for (final line in node.children) {
        _collectFromNode(line, key, out);
      }
    }
  }

  List<PlainTextRange> _resultRanges(Document document) =>
      _spansWithKey(document, ArithResultAttribute.kKey)
          .map((s) => PlainTextRange(s.start, s.end))
          .toList();

  // ── Number highlights (no text mutation) ────────────────────────────────

  void _reconcileHighlights(QuillController controller) {
    final document = controller.document;
    final text = document.toPlainText();
    final excluded = _resultRanges(document);
    final tokens = _parser.parse(text, excluded: excluded);

    final desired = <int, NumberToken>{
      for (final t in tokens) t.startOffset: t,
    };
    final existing = _spansWithKey(document, NumberHighlightAttribute.kKey);

    // Remove stale spans (moved, deleted, or wrong polarity).
    for (final span in existing) {
      final token = desired[span.start];
      final wanted = token == null
          ? null
          : (token.isNegative ? 'neg' : 'pos');
      final matches = token != null &&
          token.length == span.length &&
          wanted == span.value;
      if (!matches) {
        controller.formatText(
          span.start,
          span.length,
          NumberHighlightAttribute.unset,
          shouldNotifyListeners: false,
        );
      } else {
        desired.remove(span.start);
      }
    }

    // Add missing spans.
    for (final token in desired.values) {
      controller.formatText(
        token.startOffset,
        token.length,
        token.isNegative
            ? NumberHighlightAttribute.negative
            : NumberHighlightAttribute.positive,
        shouldNotifyListeners: false,
      );
    }
  }

  // ── Result chips (may mutate text) ──────────────────────────────────────

  void _reconcileResults(QuillController controller) {
    final document = controller.document;
    final text = document.toPlainText();
    final resultSpans = _spansWithKey(document, ArithResultAttribute.kKey);
    final excluded =
        resultSpans.map((s) => PlainTextRange(s.start, s.end)).toList();

    final resolutions = _engine.resolve(text, resultSpans: excluded);

    // Pair each resolution with an existing chip on its trigger line.
    final matchedSpans = <_Span>{};
    final ops = <_ResultOp>[];

    for (final res in resolutions) {
      final t = res.trigger;
      _Span? chip;
      for (final span in resultSpans) {
        if (span.start >= t.triggerEnd && span.start <= t.lineEnd) {
          chip = span;
          break;
        }
      }
      // Inline expression results are plain numbers (no ₹ prefix, per spec);
      // column sums keep the ₹ currency chip.
      final chipText = res.trigger.isInline
          ? _plainNumber(res.value)
          : formatAmount(res.value);
      if (chip != null) {
        matchedSpans.add(chip);
        final currentText = text.substring(chip.start, chip.end);
        if (currentText != chipText || chip.value != '${res.value}') {
          ops.add(_ResultOp.replace(chip.start, chip.length, chipText, res.value));
        }
      } else {
        ops.add(_ResultOp.insert(t.triggerEnd, chipText, res.value));
      }
    }

    // Orphaned chips (trigger removed / no numbers left in scope).
    for (final span in resultSpans) {
      if (matchedSpans.contains(span)) continue;
      // Also swallow one preceding space that we inserted with the chip.
      final hasLeadingSpace = span.start > 0 && text[span.start - 1] == ' ';
      ops.add(_ResultOp.delete(
        hasLeadingSpace ? span.start - 1 : span.start,
        hasLeadingSpace ? span.length + 1 : span.length,
      ));
    }

    if (ops.isEmpty) return;

    // Apply from the end of the document backwards so earlier offsets stay
    // valid while mutating.
    ops.sort((a, b) => b.index.compareTo(a.index));
    for (final op in ops) {
      switch (op.kind) {
        case _ResultOpKind.insert:
          final inserted = ' ${op.text}';
          controller.replaceText(
            op.index,
            0,
            inserted,
            _adjustSelection(controller.selection, op.index, inserted.length),
          );
          controller.formatText(
            op.index + 1,
            op.text.length,
            ArithResultAttribute('${op.value}'),
            shouldNotifyListeners: false,
          );
          break;
        case _ResultOpKind.replace:
          controller.replaceText(
            op.index,
            op.length,
            op.text,
            _adjustSelection(
                controller.selection, op.index, op.text.length - op.length),
          );
          controller.formatText(
            op.index,
            op.text.length,
            ArithResultAttribute('${op.value}'),
            shouldNotifyListeners: false,
          );
          break;
        case _ResultOpKind.delete:
          controller.replaceText(
            op.index,
            op.length,
            '',
            _adjustSelection(controller.selection, op.index, -op.length),
          );
          break;
      }
    }
  }

  /// Keeps the caret stable across a text mutation at [at] shifting
  /// subsequent text by [delta] characters.
  TextSelection _adjustSelection(TextSelection selection, int at, int delta) {
    int move(int offset) => offset > at ? (offset + delta).clamp(0, 1 << 30) : offset;
    return selection.copyWith(
      baseOffset: move(selection.baseOffset),
      extentOffset: move(selection.extentOffset),
    );
  }
}

enum _ResultOpKind { insert, replace, delete }

class _ResultOp {
  final _ResultOpKind kind;
  final int index;
  final int length;
  final String text;
  final double value;

  const _ResultOp._(this.kind, this.index, this.length, this.text, this.value);

  factory _ResultOp.insert(int index, String text, double value) =>
      _ResultOp._(_ResultOpKind.insert, index, 0, text, value);

  factory _ResultOp.replace(int index, int length, String text, double value) =>
      _ResultOp._(_ResultOpKind.replace, index, length, text, value);

  factory _ResultOp.delete(int index, int length) =>
      _ResultOp._(_ResultOpKind.delete, index, length, '', 0);
}
