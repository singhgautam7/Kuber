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

/// The OS navigation-bar inset (gesture pill / 3-button bar), read straight from
/// the root [FlutterView] in logical pixels.
///
/// Prefer this over `MediaQuery.viewPaddingOf`/`padding` for bottom-anchored
/// elements (sticky CTAs, the selection action bar). Inside a `Scaffold` body
/// that has a `bottomNavigationBar`, Flutter wraps the body in
/// `MediaQuery.removePadding(removeBottom: true)`, which zeroes BOTH
/// `padding.bottom` and `viewPadding.bottom` — so those report 0 and the element
/// slides under the system nav bar in edge-to-edge mode. The root view inset is
/// never zeroed by an ancestor, so it always reflects the real OS bar.
double systemNavBarInset(BuildContext context) {
  final view = View.of(context);
  return view.viewPadding.bottom / view.devicePixelRatio;
}
