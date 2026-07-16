import 'package:flutter/widgets.dart';

class KuberInfoConfig {
  final String title;
  final String description;
  final List<KuberInfoItem> items;
  final Widget? customChild;

  const KuberInfoConfig({
    required this.title,
    required this.description,
    required this.items,
    this.customChild,
  });
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
