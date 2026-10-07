import 'package:flutter/material.dart';


/// Bottom offset shared with the main nav bar (`app_scaffold.dart`): the
/// system inset, but never less than 22.
double _navBottom(BuildContext context) {
  final inset = MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
  return inset > 22 ? inset : 22.0;
}

/// Shared visibility for the extended FAB: scrolling content down hides it,
/// scrolling up (or reaching the top) shows it again, like the HeadShorts
/// reader. Driven by [KuberFabScrollWatcher] above the navigator, so screens
/// need no wiring.
final ValueNotifier<bool> kuberFabVisible = ValueNotifier<bool>(true);

/// Listens to every vertical scroll in the app and updates [kuberFabVisible].
class KuberFabScrollWatcher extends StatelessWidget {
  final Widget child;
  const KuberFabScrollWatcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        // Driven by the real scroll delta (drag and fling), not the
        // UserScrollNotification direction, which flips to "forward" at
        // the end of many upward drags.
        if (n is ScrollUpdateNotification &&
            n.metrics.axis == Axis.vertical) {
          final delta = n.scrollDelta ?? 0;
          if (n.metrics.extentBefore <= 0 || delta < -2) {
            kuberFabVisible.value = true;
          } else if (delta > 2) {
            kuberFabVisible.value = false;
          }
        }
        return false;
      },
      child: child,
    );
  }
}

/// The primary create action of a pushed list screen: an extended FAB at the
/// bottom centre with the main nav bar's metrics (56 high, stadium,
/// primaryContainer, the same bottom offset) and the same surface fade
/// behind it. It slides away while scrolling down and back on scrolling up.
///
/// Use as `Scaffold.floatingActionButton` with [kuberFabLocation]. Lists
/// should leave [KuberExtendedFab.clearance] of bottom padding so the last
/// row can scroll clear of it.
class KuberExtendedFab extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const KuberExtendedFab({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// Bottom padding a list needs so its last item clears the FAB.
  static const double clearance = 56 + 22 + 32;

  @override
  State<KuberExtendedFab> createState() => _KuberExtendedFabState();
}

class _KuberExtendedFabState extends State<KuberExtendedFab> {
  @override
  void initState() {
    super.initState();
    // A newly opened screen always starts with its FAB showing.
    kuberFabVisible.value = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottom = _navBottom(context);
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // The nav bar's scrim: content fades out under the button.
          Positioned(
            left: 0,
            right: 0,
            bottom: -bottom,
            height: bottom + 56 + 32,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.surface.withValues(alpha: 0),
                      cs.surface.withValues(alpha: 0.92),
                      cs.surface,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: kuberFabVisible,
            builder: (context, visible, child) => AnimatedSlide(
              offset: visible ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 220),
              curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(ignoring: !visible, child: child),
              ),
            ),
            child: Material(
              color: cs.primaryContainer,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onPressed,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.only(left: 20, right: 24),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, size: 24, color: cs.onPrimaryContainer),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: theme.textTheme.labelLarge!
                            .copyWith(color: cs.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom centre, at the main nav bar's bottom offset.
const FloatingActionButtonLocation kuberFabLocation = _KuberFabLocation();

class _KuberFabLocation extends FloatingActionButtonLocation {
  const _KuberFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry g) {
    final inset = g.minViewPadding.bottom;
    final bottom = inset > 22 ? inset : 22.0;
    final x = (g.scaffoldSize.width - g.floatingActionButtonSize.width) / 2;
    final y = g.contentBottom - g.floatingActionButtonSize.height - bottom;
    return Offset(x, y);
  }
}
