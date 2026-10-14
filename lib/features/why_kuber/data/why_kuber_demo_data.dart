import 'package:flutter/widgets.dart';

import '../../../core/utils/color_harmonizer.dart';

/// Raw category colours of the sample data, the same values the seed data
/// uses. Always passed through [harmonizeCategory] before drawing.
class DemoCat {
  static const food = Color(0xFFFF5722);
  static const transport = Color(0xFFFF9800);
  static const fun = Color(0xFFE91E63);
  static const groceries = Color(0xFF4CAF50);
  static const shopping = Color(0xFF3F51B5);
  static const petCare = Color(0xFFFF7043);
  static const travel = Color(0xFF03A9F4);

  static Color of(BuildContext context, Color raw) =>
      harmonizeCategory(context, raw);
}
