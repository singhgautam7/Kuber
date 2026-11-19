import 'package:flutter/material.dart';

import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../data/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final harmonized = harmonizeCategory(context, Color(category.colorValue));

    return KuberChip(
      label: category.name,
      selected: selected,
      icon: IconMapper.fromString(category.icon),
      iconColor: harmonized,
      onTap: onTap,
    );
  }
}
