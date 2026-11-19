import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';

/// Insert / first-load motion for SHORT lists on a landing screen
/// (motion.md "Lists"). Keep one in the screen's State and wrap each row with
/// [item]. Rows present on the first build stagger in (max 6, first show of
/// the page only); a row whose id appears later grows in. Removal is not
/// animated here (the data source drops the row at once). Never use for long
/// lists.
class ListMotion {
  final Set<Object> _seen = {};
  bool _first = true;
  bool _armed = false;

  Widget item(BuildContext context, Object id, int index, Widget child) {
    if (!_armed) {
      _armed = true;
      // After the first frame of rows, later ids count as inserts.
      WidgetsBinding.instance.addPostFrameCallback((_) => _first = false);
    }
    final isNew = _seen.add(id);
    return KuberAnimatedListItem(
      key: ValueKey(id),
      animateIn: isNew && !_first,
      child: StaggeredEntrance(
        index: index,
        animate: isNew && _first && index < KuberMotion.staggerLimit,
        child: child,
      ),
    );
  }
}
