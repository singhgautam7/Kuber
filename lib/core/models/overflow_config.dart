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
  final VoidCallback onTap;
  final bool isDestructive;

  const KuberOverflowItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}
