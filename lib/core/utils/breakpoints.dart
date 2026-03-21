import 'package:flutter/material.dart';

class KuberBreakpoints {
  static const double phone = 600;
  static const double smallTablet = 840;
}

/// Returns the bottom padding needed to clear the floating nav bar on phone,
/// or 0 on wide screens that use a side rail.
double navBarBottomPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= KuberBreakpoints.smallTablet) return 0;
  final safeBottom = MediaQuery.of(context).padding.bottom;
  return safeBottom + 80; // safeBottom + 64px nav + 8px margin + 8px clearance
}
