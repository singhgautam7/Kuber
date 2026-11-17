import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/l10n_ext.dart';

// ---------------------------------------------------------------------------
// Nav item data
// ---------------------------------------------------------------------------

String localNavLabel(BuildContext context, String label) {
  switch (label) {
    case 'Home':
      return context.l10n.navHome;
    case 'History':
      return context.l10n.navHistory;
    case 'Analytics':
      return context.l10n.navAnalytics;
    case 'More':
      return context.l10n.navMore;
    default:
      return label;
  }
}

class KuberNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const KuberNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const kuberNavItems = [
  KuberNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  KuberNavItem(
    icon: Icons.receipt_outlined,
    activeIcon: Icons.receipt_rounded,
    label: 'History',
  ),
  KuberNavItem(
    icon: Icons.insert_chart_outlined,
    activeIcon: Icons.insert_chart_rounded,
    label: 'Analytics',
  ),
  KuberNavItem(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    label: 'More',
  ),
];

// ---------------------------------------------------------------------------
// Destination glyphs: drawn in the Perch language of the board's house glyph,
// 20x16 art in a 24 slot, 1.75 stroke, rounded. Always outlined: the active
// tab changes colour only (user review round 2).
// ---------------------------------------------------------------------------

class KuberNavGlyph extends StatelessWidget {
  final int index;
  final Color color;

  const KuberNavGlyph({
    super.key,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: CustomPaint(
          size: const Size(20, 16),
          painter: _NavGlyphPainter(index, color),
        ),
      ),
    );
  }
}

class _NavGlyphPainter extends CustomPainter {
  final int index;
  final Color color;

  _NavGlyphPainter(this.index, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (index) {
      case 0: // house
        final p = Path()
          ..moveTo(3, 7.4)
          ..lineTo(10, 1.8)
          ..lineTo(17, 7.4)
          ..lineTo(17, 13.2)
          ..arcToPoint(const Offset(15.4, 14.8), radius: const Radius.circular(1.6))
          ..lineTo(4.6, 14.8)
          ..arcToPoint(const Offset(3, 13.2), radius: const Radius.circular(1.6))
          ..close();
        canvas.drawPath(p, stroke);
      case 1: // receipt: a rounded sheet with three rules
        final sheet = RRect.fromRectAndRadius(
            const Rect.fromLTRB(3, 0.9, 17, 15.1), const Radius.circular(2.6));
        final rule = Paint()
          ..color = color
          ..strokeWidth = 1.75
          ..strokeCap = StrokeCap.round;
        canvas.drawRRect(sheet, stroke);
        canvas.drawLine(const Offset(6.6, 5), const Offset(13.4, 5), rule);
        canvas.drawLine(const Offset(6.6, 8), const Offset(13.4, 8), rule);
        canvas.drawLine(const Offset(6.6, 11), const Offset(10.6, 11), rule);
      case 2: // chart: a rounded frame holding three bars
        final frame = RRect.fromRectAndRadius(
            const Rect.fromLTRB(1.6, 0.9, 18.4, 15.1), const Radius.circular(3));
        final bar = Paint()..color = color;
        canvas.drawRRect(frame, stroke);
        for (final (x, top) in [(5.0, 7.6), (8.9, 4.4), (12.8, 9.2)]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTRB(x, top, x + 2.3, 11.8),
                const Radius.circular(1.15)),
            bar,
          );
        }
      default: // grid: four rounded tiles
        for (final o in const [
          Offset(2.4, 0.9),
          Offset(10.8, 0.9),
          Offset(2.4, 8.3),
          Offset(10.8, 8.3),
        ]) {
          final r = RRect.fromRectAndRadius(
              o & const Size(6.8, 6.8), const Radius.circular(2.2));
          canvas.drawRRect(r, stroke);
        }
    }
  }

  @override
  bool shouldRepaint(_NavGlyphPainter o) =>
      o.index != index || o.color != color;
}

// ---------------------------------------------------------------------------
// Floating pill + FAB (components/bottom-nav.md). Copied from Perch
// `lib/app/nav_bar.dart` (PerchNavPill, _NavItem, PerchFab). Changes: Kuber
// glyphs and labels, long-press hooks, no shadow (open decision 4), FAB in
// primaryContainer.
// ---------------------------------------------------------------------------

class KuberNavPill extends StatelessWidget {
  const KuberNavPill({
    super.key,
    required this.index,
    required this.onSelect,
    this.onLongPress,
    this.showLabels = true,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback? onLongPress;

  /// False on narrow screens / large text where the label wouldn't fit.
  final bool showLabels;

  /// Width of the pill: border 2, padding 16, items 40 (24 glyph + 8 + 8),
  /// 2 between items; the selected one adds 11 + 8 + label + 14 - 16.
  static double widthFor(BuildContext context, {required bool withLabel}) {
    var w = 2.0 + 16 + kuberNavItems.length * 40 + (kuberNavItems.length - 1) * 2;
    if (!withLabel) return w;
    var label = 0.0;
    for (final item in kuberNavItems) {
      final lw = _labelWidth(context, localNavLabel(context, item.label));
      if (lw > label) label = lw;
    }
    return w + 17 + label;
  }

  /// Width of [label] at the heavier (selected) weight, which is what the
  /// label slot reserves.
  static double _labelWidth(BuildContext context, String label) {
    final style = KuberMotion.weightStyle(
        Theme.of(context).textTheme.labelLarge!, 700);
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = tp.width;
    tp.dispose();
    return w;
  }

  /// Left / right edge of the indicator around item [i] at rest, in the
  /// coordinates of the row inside the pill (border 1 + padding 8 are outside).
  static (double, double) _indicatorEdges(
      int i, bool withLabel, double labelW) {
    final left = i * 42.0;
    return (left, left + 40 + (withLabel ? 17 + labelW : 0));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labels = [
      for (final item in kuberNavItems) localNavLabel(context, item.label),
    ];
    final labelOk = showLabels && MediaQuery.textScalerOf(context).scale(14) <= 20;
    final (left, right) = _indicatorEdges(
        index, labelOk, labelOk ? _labelWidth(context, labels[index]) : 0);
    return RepaintBoundary(
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(KuberSpace.sm),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: KuberShape.fullR,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Stack(
          children: [
            // The indicator is one painter driven by two spring values; the
            // items on top never repaint it.
            Positioned.fill(
              child: NavIndicator(
                left: left,
                right: right,
                color: cs.secondaryContainer,
                destination: index,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                for (int i = 0; i < kuberNavItems.length; i++)
                  _PillItem(
                    index: i,
                    label: labels[i],
                    selected: i == index,
                    showLabel: labelOk,
                    onTap: () {
                      if (i != index) KuberHaptics.tick();
                      onSelect(i);
                    },
                    onLongPress: onLongPress,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The selection pill behind the nav items. Moving: the edge on the side it
/// moves toward (leading) follows springFast, the other (trailing) follows
/// springDefault, so it stretches mid-way (up to about 1.3x). Subtle: both
/// edges on springSubtle. Off: the old pill cross-fades into the new one.
class NavIndicator extends StatefulWidget {
  const NavIndicator({
    super.key,
    required this.left,
    required this.right,
    required this.color,
    required this.destination,
  });

  final double left;
  final double right;
  final Color color;

  /// Which destination it sits on (keys the Off cross-fade).
  final int destination;

  @override
  State<NavIndicator> createState() => _NavIndicatorState();
}

class _NavIndicatorState extends State<NavIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _l =
      AnimationController.unbounded(vsync: this, value: widget.left);
  late final AnimationController _r =
      AnimationController.unbounded(vsync: this, value: widget.right);

  @override
  void didUpdateWidget(NavIndicator old) {
    super.didUpdateWidget(old);
    if (old.left == widget.left && old.right == widget.right) return;
    final level = KuberMotion.levelOf(context);
    if (level == MotionLevel.off) {
      _l.value = widget.left;
      _r.value = widget.right;
      return;
    }
    final movingRight = widget.left > old.left;
    final fast = KuberMotion.spatial(level, KuberMotion.springFast);
    final slow = KuberMotion.spatial(level, KuberMotion.springDefault);
    _l.springTo(widget.left, movingRight ? slow : fast);
    _r.springTo(widget.right, movingRight ? fast : slow);
  }

  @override
  void dispose() {
    _l.dispose();
    _r.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (KuberMotion.levelOf(context) == MotionLevel.off) {
      return AnimatedSwitcher(
        duration: KuberMotion.fxInstant,
        child: SizedBox.expand(
          key: ValueKey(widget.destination),
          child: CustomPaint(
            painter: _IndicatorPainter(
                ValueNotifier(widget.left), ValueNotifier(widget.right),
                widget.color),
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: CustomPaint(
        painter: _IndicatorPainter(_l, _r, widget.color),
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter(this.l, this.r, this.color)
      : super(repaint: Listenable.merge([l, r]));
  final ValueListenable<double> l;
  final ValueListenable<double> r;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final left = l.value, right = r.value;
    if (right <= left) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(left, 0, right, size.height),
          Radius.circular(size.height / 2)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_IndicatorPainter o) => o.color != color || o.l != l || o.r != r;
}

class _PillItem extends StatefulWidget {
  const _PillItem({
    required this.index,
    required this.label,
    required this.selected,
    required this.showLabel,
    required this.onTap,
    this.onLongPress,
  });

  final int index;
  final String label;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_PillItem> createState() => _PillItemState();
}

class _PillItemState extends State<_PillItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final level = KuberMotion.levelOf(context);
    final fg = widget.selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    // Under a large OS text scale the label drops first; the glyph and the
    // indicator still say where you are.
    final wantLabel = widget.showLabel && widget.selected;
    final curve = KuberMotion.spatialCurve(level, KuberMotion.defaultCurve);

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: 40,
          // Label width 0 -> auto on springDefault (clamped: it never goes
          // negative); the glyph and padding grow with it.
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: wantLabel ? 1.0 : 0.0),
            duration: level == MotionLevel.off
                ? Duration.zero
                : curve.clamped.settle,
            curve: curve.clamped,
            builder: (context, t, _) => TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: fg),
              duration: level == MotionLevel.off
                  ? Duration.zero
                  : KuberMotion.fxFast,
              curve: KuberMotion.curveEffects,
              builder: (context, color, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8 + 3 * t),
                  AnimatedScale(
                    scale: _pressed && level != MotionLevel.off ? 0.9 : 1,
                    duration: KuberMotion.fastCurve.settle,
                    curve: KuberMotion.fastCurve,
                    child: KuberNavGlyph(index: widget.index, color: color!),
                  ),
                  if (t > 0.001)
                    ClipRect(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: t,
                        child: Opacity(
                          opacity: t,
                          child: Padding(
                            padding: const EdgeInsets.only(left: KuberSpace.sm),
                            child: AnimatedWeight(
                              widget.label,
                              isActive: widget.selected,
                              style: theme.textTheme.labelLarge!
                                  .copyWith(color: color),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 8 + 6 * t),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular Add button beside the pill (Perch `PerchFab`): 56, the
/// primaryContainer fill, scale 0.96 and corners 28 -> 12 under the finger.
class KuberNavFab extends StatelessWidget {
  const KuberNavFab({
    super.key,
    required this.onTap,
    this.onLongPress,
    this.semanticLabel = 'Add transaction',
  });

  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
        kind: PressKind.fab,
        restRadius: 28,
        onTap: onTap,
        onLongPress: onLongPress,
        builder: (context, radius, pressed) => Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
                cs.onPrimaryContainer
                    .withValues(alpha: 0.1 * pressed.clamp(0.0, 1.0)),
                cs.primaryContainer),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(Icons.add_rounded, color: cs.onPrimaryContainer, size: 26),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Side navigation rail (large tablet / desktop >= 840dp)
// ---------------------------------------------------------------------------

class KuberNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onAddTapped;

  const KuberNavRail({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.onAddTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMoreTab = currentIndex == 3;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(right: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Text(
                'Kuber',
                style: theme.textTheme.titleLarge!.copyWith(color: cs.primary),
              ),
            ),
            for (var i = 0; i < kuberNavItems.length; i++)
              _RailItem(
                index: i,
                label: localNavLabel(context, kuberNavItems[i].label),
                isActive: i == currentIndex,
                onTap: () {
                  if (i != currentIndex) KuberHaptics.tick();
                  onTabTapped(i);
                },
              ),
            const Spacer(),
            // Add button: hidden on More tab
            if (!isMoreTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Material(
                  color: cs.primaryContainer,
                  shape: const StadiumBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      KuberHaptics.tick();
                      onAddTapped();
                    },
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              color: cs.onPrimaryContainer, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.addTransaction,
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
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RailItem({
    required this.index,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = isActive ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? cs.secondaryContainer : Colors.transparent,
        animationDuration: KuberMotion.of(context, KuberMotion.fxFast),
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                KuberNavGlyph(
                  index: index,
                  color: fg,
                ),
                const SizedBox(width: 12),
                AnimatedWeight(label,
                    isActive: isActive,
                    style: theme.textTheme.labelLarge!.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
