import 'package:flutter/widgets.dart';

class KuberInfoConfig {
  final String title;
  final String description;
  final List<KuberInfoItem> items;
  final Widget? customChild;

  /// Money "i" sheets: an "Example" block with real, computed numbers.
  final KuberInfoExampleBlock? exampleBlock;

  /// Overrides the pinned button label (money "i" sheets use "Got it",
  /// tonal).
  final String? actionLabel;

  const KuberInfoConfig({
    required this.title,
    required this.description,
    this.items = const [],
    this.customChild,
    this.exampleBlock,
    this.actionLabel,
  });
}

/// Example block (components/info-sheet.md): an optional sentence, up to 4
/// label / value rows (one may be highlighted), an optional closing line.
class KuberInfoExampleBlock {
  final String label;
  final String? sentence;
  final List<KuberInfoExampleRow> rows;
  final String? after;
  const KuberInfoExampleBlock({
    required this.label,
    this.sentence,
    this.rows = const [],
    this.after,
  });
}

class KuberInfoExampleRow {
  final String label;
  final String value;
  final bool highlight;
  const KuberInfoExampleRow(this.label, this.value, {this.highlight = false});
}

class KuberInfoItem {
  final IconData icon;
  final String title;
  final String description;

  /// Optional boxed mini-example rendered under the description (per the
  /// "HOW ARITHMETIC WORKS" section in the Notes info design).
  final KuberInfoExample? example;

  const KuberInfoItem({
    required this.icon,
    required this.title,
    required this.description,
    this.example,
  });
}

/// A two-line worked example: an input [expression] line, then a [trigger]
/// word followed by a highlighted [result] chip (e.g. "60, 45, 90" / "total"
/// + "₹195").
class KuberInfoExample {
  final String expression;
  final String trigger;
  final String result;

  const KuberInfoExample({
    required this.expression,
    required this.trigger,
    required this.result,
  });
}
