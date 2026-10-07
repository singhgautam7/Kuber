import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(KuberSpace.sm),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: KuberShape.fullR,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            for (int i = 0; i < kuberNavItems.length; i++)
              _PillItem(
                index: i,
                label: localNavLabel(context, kuberNavItems[i].label),
                selected: i == index,
                onTap: () => onSelect(i),
                onLongPress: onLongPress,
              ),
          ],
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  const _PillItem({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    // Under a large OS text scale the label drops first; the glyph and the
    // indicator still say where you are.
    final showLabel =
        selected && MediaQuery.textScalerOf(context).scale(14) <= 20;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: KuberMotion.of(context, KuberMotion.navIndicator),
          curve: KuberMotion.curveOf(context, KuberMotion.spring),
          height: 40,
          padding: EdgeInsets.only(
            left: showLabel ? 11 : 8,
            right: showLabel ? 14 : 8,
          ),
          decoration: BoxDecoration(
            color: selected ? cs.secondaryContainer : Colors.transparent,
            borderRadius: KuberShape.fullR,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: showLabel ? KuberSpace.sm : 0,
            children: [
              KuberNavGlyph(
                index: index,
                color: fg,
              ),
              AnimatedSize(
                duration: KuberMotion.of(context, KuberMotion.navIndicator),
                curve: KuberMotion.curveOf(context, KuberMotion.spring),
                child: showLabel
                    ? Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        style: theme.textTheme.labelLarge!.copyWith(color: fg),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The circular Add button beside the pill (Perch `PerchFab`): 56, the
/// primaryContainer fill, a 0.94 squash under the finger.
class KuberNavFab extends StatefulWidget {
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
  State<KuberNavFab> createState() => _KuberNavFabState();
}

class _KuberNavFabState extends State<KuberNavFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 40),
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: _pressed
                  ? Color.alphaBlend(
                      cs.onPrimaryContainer.withValues(alpha: 0.1),
                      cs.primaryContainer)
                  : cs.primaryContainer,
              borderRadius: KuberShape.fullR,
            ),
            child: Icon(Icons.add_rounded, color: cs.onPrimaryContainer, size: 26),
          ),
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
                onTap: () => onTabTapped(i),
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
                      HapticFeedback.mediumImpact();
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
                Text(label,
                    style: theme.textTheme.labelLarge!.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
