import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

Color harmonizeCategory(BuildContext context, Color rawColor) {
  final primary = Theme.of(context).colorScheme.primary;
  return rawColor.harmonizeWith(primary);
}
