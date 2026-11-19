import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import 'quick_nav_model.dart';

/// The real stack for a jump, read fresh each time (it changes as pages pop).
typedef QuickNavStackReader = List<QuickNavStackEntry> Function();

/// Takes the user to [target] with one fade-through, building the back stack
/// underneath so Back follows the tree:
///
///  * target already on the stack: pop to it, route by route, so a page with
///    unsaved changes gets to ask (a cancel stops the jump there);
///  * otherwise: pop only what the path to the target does not share, then
///    push the missing pages on the path (a tab switch first when needed).
///
/// Everything happens under a full-screen curtain, so no in-between page shows.
Future<void> quickNavJump({
  required NavigatorState nav,
  required GoRouter router,
  required QvNode target,
  required QuickNavStackReader readStack,
  required Route<dynamic>? Function() topRoute,
  required int Function() currentTab,
  required Color curtainColor,
  required bool reduced, // Off: the same fade, 90 ms both ways
}) async {
  final overlay = nav.overlay;
  final curtain = overlay == null
      ? null
      : _Curtain.show(overlay, curtainColor, KuberMotion.fxInstant, reduced);
  try {
    await curtain?.covered;
    bool onStack(Route<dynamic> r) => readStack().any((e) => identical(e.route, r));

    Future<bool> popTo(int keep) async {
      while (readStack().length > keep) {
        final top = readStack().last.route;
        if (top == null) return false;
        // A page with no pop guard just goes, all of them in one frame; one
        // that guards (unsaved changes) is asked, and may stay.
        if (top.popDisposition == RoutePopDisposition.pop && !top.willHandlePopInternally) {
          nav.pop();
        } else if (!await _popOne(nav, top, onStack, topRoute, curtain)) {
          return false;
        }
      }
      return true;
    }

    final stack = readStack();
    final tab = QuickNavModel.tabOf(target);
    final onIt = target.route == null ? -1 : stack.indexWhere((e) => identical(e.route, target.route));
    if (onIt >= 0) {
      await popTo(onIt + 1);
    } else if (target.isTab) {
      if (!await popTo(0)) return;
      if (tab.node.tab != currentTab()) await _go(router, target.node.route!);
    } else {
      final chain = [
        for (final n in [...target.ancestors.toList().reversed, target])
          if (!n.isTab && n.node.location != null) n,
      ];
      var k = 0;
      if (tab.node.tab == currentTab()) {
        while (k < stack.length && k < chain.length && stack[k].location == chain[k].node.route) {
          k++;
        }
      }
      if (!await popTo(k)) return;
      if (k == 0 && tab.node.tab != currentTab()) await _go(router, tab.node.route!);
      for (final n in chain.skip(k)) {
        final loc = n.node.location!;
        unawaited(router.push<void>(loc));
        await _arrived(router, Uri.parse(loc).path);
      }
      await _settled(topRoute());
    }
    assert(() {
      debugPrint('KUBER_NAV depth=${readStack().length + 1}');
      return true;
    }());
  } finally {
    await curtain?.remove();
  }
}

// A short timer, not endOfFrame: waiting on a prompt must not keep frames
// coming while the user reads it.
Future<void> _frame() => Future<void>.delayed(const Duration(milliseconds: 16));

/// One route off the stack through its own pop guard. True once it is gone;
/// false when it stayed (the user answered "keep editing" or it blocked).
Future<bool> _popOne(
  NavigatorState nav,
  Route<dynamic> r,
  bool Function(Route<dynamic>) onStack,
  Route<dynamic>? Function() top,
  _Curtain? curtain,
) async {
  unawaited(nav.maybePop());
  var prompted = false;
  var quiet = 0;
  for (var i = 0; i < 1800; i++) {
    await _frame();
    if (!onStack(r)) {
      if (prompted) curtain?.cover();
      return true;
    }
    if (!identical(top(), r)) {
      // A prompt is open: lift the curtain so it can be seen and answered.
      if (!prompted) curtain?.lift();
      prompted = true;
      quiet = 0;
    } else if (++quiet >= 6) {
      if (prompted) curtain?.cover();
      return false;
    }
  }
  return false;
}

Future<void> _go(GoRouter router, String loc) async {
  router.go(loc);
  await _arrived(router, loc);
}

/// Waits for the router to report [path] as its location (a few frames).
Future<void> _arrived(GoRouter router, String path) async {
  for (var i = 0; i < 90; i++) {
    await _frame();
    final cfg = router.routerDelegate.currentConfiguration;
    if (cfg.uri.path == path || (cfg.isNotEmpty && cfg.last.matchedLocation == path)) return;
  }
}

/// Lets the page that was pushed last finish its transition, so the curtain
/// goes up on a finished screen.
Future<void> _settled(Route<dynamic>? r) async {
  final a = r is TransitionRoute ? r.animation : null;
  for (var i = 0; i < 60 && a != null && !a.isCompleted; i++) {
    await _frame();
  }
}

/// A full-screen surface that fades in over the old screen and out again
/// over the new one (the fade-through).
class _Curtain {
  final AnimationController _c;
  final OverlayEntry _entry;
  _Curtain._(this._c, this._entry);

  /// Fade-through: covers in fx.instant, uncovers in fx.fast (Off: 90 ms).
  static _Curtain show(OverlayState overlay, Color color, Duration d, bool off) {
    final c = AnimationController(
        vsync: overlay, duration: d, reverseDuration: off ? KuberMotion.fxInstant : KuberMotion.fxFast);
    final entry = OverlayEntry(
      // Blocks taps only while it is up, so a prompt under a lifted curtain
      // can be answered.
      builder: (_) => ListenableBuilder(
        listenable: c,
        builder: (_, child) => IgnorePointer(ignoring: c.value == 0, child: child),
        child: FadeTransition(opacity: CurvedAnimation(parent: c, curve: KuberMotion.curveEffects), child: ColoredBox(color: color, child: const SizedBox.expand())),
      ),
    );
    overlay.insert(entry);
    c.forward();
    return _Curtain._(c, entry);
  }

  Future<void> get covered => _c.forward().orCancel.catchError((_) {});
  void cover() => _c.forward();
  void lift() => _c.value = 0;

  Future<void> remove() async {
    await _c.reverse().orCancel.catchError((_) {});
    _entry.remove();
    _entry.dispose();
    _c.dispose();
  }
}
