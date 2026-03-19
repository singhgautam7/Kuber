import 'package:flutter/material.dart';

import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
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

    return ChoiceChip(
      selected: selected,
      label: Text(category.name),
      avatar: Icon(
        IconMapper.fromString(category.icon),
        size: 18,
        color: harmonized,
      ),
      onSelected: (_) => onTap?.call(),
    );
  }
}
