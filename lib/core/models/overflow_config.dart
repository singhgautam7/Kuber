import 'package:flutter/widgets.dart';

class KuberOverflowConfig {
  final List<KuberOverflowItem> items;

  const KuberOverflowConfig({
    required this.items,
  });
}

class KuberOverflowItem {
  final IconData icon;
  final String label;

  /// Optional helper line under the label.
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  /// Shows a check (radio-style choices such as "Sort: Modified").
  final bool selected;

  /// Starts a new group in the menu (a divider above this item).
  final bool dividerBefore;

  const KuberOverflowItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.selected = false,
    this.dividerBefore = false,
  });
}
