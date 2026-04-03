import 'package:flutter/widgets.dart';

class KuberInfoConfig {
  final String title;
  final String description;
  final List<KuberInfoItem> items;

  const KuberInfoConfig({
    required this.title,
    required this.description,
    required this.items,
  });
}

class KuberInfoItem {
  final IconData icon;
  final String title;
  final String description;

  const KuberInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
