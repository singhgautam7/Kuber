import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color rawColor;
  final double size;
  final double borderRadius;

  const CategoryIcon.square({
    super.key,
    required this.icon,
    required this.rawColor,
    this.size = 48,
  }) : borderRadius = 8;

  const CategoryIcon.roundedSquare({
    super.key,
    required this.icon,
    required this.rawColor,
    this.size = 64,
  }) : borderRadius = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: rawColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        icon,
        color: rawColor,
        size: size * 0.5,
      ),
    );
  }
}
