import 'package:flutter/material.dart';

import 'quick_nav_tree.dart';

/// One page on the real back stack (bottom first, the tab shell left out).
class QuickNavStackEntry {
  final Route<dynamic>? route;

  /// Full location without query, when the router knows it.
  final String? location;
  final String title;
  final IconData icon;
  const QuickNavStackEntry({this.route, this.location, required this.title, required this.icon});
}

/// A node of the tree as shown for one open: the static node, or a virtual leaf
/// for a page the tree does not list (a loan, a form, transaction detail).
class QvNode {
  final QuickNavNode node;
  final QvNode? parent;
  final List<QvNode> kids;
  bool current = false;

  /// The stack route this node is, when it is on the back stack.
  Route<dynamic>? route;

  QvNode(this.node, this.parent, this.kids);

  String get id => node.id;
  bool get isFolder => kids.isNotEmpty;
  bool get isTab => node.tab != null;

  bool get onPath => current || kids.any((k) => k.onPath);

  Iterable<QvNode> get ancestors sync* {
    for (var p = parent; p != null; p = p.parent) {
      yield p;
    }
  }
}

/// What the sheet shows: the tab roots with the current page marked.
class QuickNavModel {
  final List<QvNode> tabs;
  final QvNode current;
  QuickNavModel(this.tabs, this.current);

  /// Home and More always; History and Analytics only when the page sits
  /// under them.
  List<QvNode> get roots => [for (final t in tabs) if (t.node.tab == 0 || t.node.tab == 3 || t.onPath) t];

  /// Builds the model. Pages found by location become the static nodes;
  /// others become a leaf under the page before them on the stack, so the
  /// path always ends at the page the user is on.
  factory QuickNavModel.build(List<QuickNavNode> roots, List<QuickNavStackEntry> stack, int tab) {
    final byLocation = <String, QvNode>{};
    QvNode wrap(QuickNavNode n, QvNode? parent) {
      final qv = QvNode(n, parent, []);
      for (final c in n.children) {
        qv.kids.add(wrap(c, qv));
      }
      final r = n.route;
      if (r != null) byLocation.putIfAbsent(r, () => qv);
      return qv;
    }

    final tabs = [for (final r in roots) wrap(r, null)];
    var current = tabs.firstWhere((t) => t.node.tab == tab, orElse: () => tabs.first);
    var parent = current;
    var virtualN = 0;
    for (final e in stack) {
      final found = e.location == null ? null : byLocation[e.location];
      final QvNode qv;
      if (found != null && !found.isTab) {
        qv = found;
      } else {
        qv = QvNode(
          QuickNavNode(id: 'v:${virtualN++}', title: e.title, icon: e.icon, route: e.location),
          parent,
          [],
        );
        parent.kids.add(qv);
      }
      qv.route = e.route;
      parent = qv;
      current = qv;
    }
    current.current = true;
    // A found page sits under its own static parent, whatever the stack was.
    return QuickNavModel(tabs, current);
  }

  /// The tab at the top of [n]'s path.
  static QvNode tabOf(QvNode n) {
    var t = n;
    while (t.parent != null) {
      t = t.parent!;
    }
    return t;
  }
}

/// What a folder shows of its children, and whether a "Show remaining" row
/// follows. Pure so the view and the tests read the same rule.
class QuickNavKids {
  final List<QvNode> shown;

  /// Children left out (0 = no row); [showFewer] when everything is shown but
  /// the list is long.
  final int remaining;
  final bool showFewer;
  const QuickNavKids(this.shown, this.remaining, this.showFewer);

  static QuickNavKids of(QvNode n, {required bool all}) {
    final kids = n.kids;
    if (kids.length <= quickNavLongList) return QuickNavKids(kids, 0, false);
    if (all) return QuickNavKids(kids, 0, true);
    final ends = n.node.sectionEnds;
    final onPath = kids.indexWhere((k) => k.onPath);
    var sec = 0;
    if (onPath >= 0 && ends.isNotEmpty) {
      sec = ends.indexWhere((e) => onPath < e);
      if (sec < 0) sec = ends.length - 1;
    }
    final start = sec == 0 || ends.isEmpty ? 0 : ends[sec - 1];
    final end = ends.isEmpty ? kids.length : (sec == ends.length - 1 ? kids.length : ends[sec]);
    final shown = kids.sublist(start, end);
    return QuickNavKids(shown, kids.length - shown.length, false);
  }
}
