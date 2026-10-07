import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/color_harmonizer.dart';

/// Category tile (components/transaction-item.md): radius 12, the category
/// colour re-toned to a container tone with the glyph in the strong tone.
class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color rawColor;
  final double size;

  const CategoryIcon.square({
    super.key,
    required this.icon,
    required this.rawColor,
    this.size = 40,
  });

  const CategoryIcon.roundedSquare({
    super.key,
    required this.icon,
    required this.rawColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final tones = categoryTones(context, rawColor);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tones.container,
        borderRadius: KuberShape.mediumR,
      ),
      child: Icon(icon, color: tones.fg, size: size * 0.55),
    );
  }
}
