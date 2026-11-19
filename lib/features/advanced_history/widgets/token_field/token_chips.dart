import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../query/query_ast.dart';
import '../../query/query_labels.dart';
import 'package:kuber/core/motion/motion.dart';

/// Dashed rounded-rect border (implied group, ghost bracket).
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dash = 5,
    this.gap = 4,
  });
  final Color color;
  final double radius, strokeWidth, dash, gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final PathMetric m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += dash + gap) {
        canvas.drawPath(m.extractPath(d, math.min(d + dash, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter o) =>
      o.color != color || o.radius != radius || o.strokeWidth != strokeWidth;
}

/// Entrance for a token inserted at the cursor: scale 0.85 to 1 on
/// expressiveFastSpatial with a primaryContainer flash; exit scale + fade.
class TokenEntrance extends StatefulWidget {
  const TokenEntrance({
    super.key,
    required this.animate,
    required this.removing,
    required this.child,
  });
  final bool animate, removing;
  final Widget child;

  @override
  State<TokenEntrance> createState() => _TokenEntranceState();
}

class _TokenEntranceState extends State<TokenEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _c.value = widget.animate ? 0 : 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && widget.animate) {
      _started = true;
      if (KuberMotion.levelOf(context) == MotionLevel.off) {
        _c.value = 1;
      } else {
        _c.duration = Duration(
            milliseconds:
                math.max(600, KuberMotion.fastCurve.settle.inMilliseconds));
        _c.forward();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = KuberMotion.levelOf(context);
    final reduced = level == MotionLevel.off;
    final curve = KuberMotion.spatialCurve(level, KuberMotion.fastCurve);
    return AnimatedScale(
      scale: widget.removing && !reduced ? 0.8 : 1,
      duration: KuberMotion.fxInstant,
      curve: KuberMotion.curveEffects,
      child: AnimatedOpacity(
        opacity: widget.removing ? 0 : 1,
        duration: KuberMotion.fxInstant,
        curve: KuberMotion.curveEffects,
        child: AnimatedBuilder(
          animation: _c,
          child: widget.child,
          builder: (context, child) {
            final t = _c.value;
            final s = reduced ? 1.0 : 0.85 + 0.15 * curve.transform(t);
            return Transform.scale(scale: s, child: child);
          },
        ),
      ),
    );
  }
}

/// One sealed filter. 32 dp, r8, surfaceContainerLowest, 1 dp outlineVariant.
class TokenChip extends StatelessWidget {
  const TokenChip({
    super.key,
    required this.item,
    required this.money,
    required this.selected,
    required this.editing,
    required this.negated,
    required this.flashing,
    required this.error,
    required this.onTap,
  });

  final TokenItem item;
  final String Function(double) money;
  final bool selected, editing, negated, flashing, error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final c = item.condition;
    final bad = c == null || error;
    final d = c == null ? null : tokenDisplay(c, l, money);
    final fg = selected ? cs.onPrimary : cs.onSurface;
    final Color bg = selected
        ? cs.primary
        : flashing
            ? cs.primaryContainer
            : cs.surfaceContainerLowest;
    final Color edge = bad
        ? cs.error
        : negated
            ? cs.error
            : editing
                ? cs.primary
                : cs.outlineVariant;
    final width = bad ? 2.0 : (negated || editing ? 1.5 : 1.0);
    final valueStyle = localeFont(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: bad && !selected ? cs.error : fg,
      decoration: bad ? TextDecoration.underline : null,
    ).copyWith(
      decorationStyle: TextDecorationStyle.wavy,
      decorationColor: cs.error,
    );
    final isWords = c?.field == QueryField.words;
    final semantic = c == null
        ? l.ahfTokenInvalidSemantics(item.text)
        : l.ahfTokenSemantics(d!.field.isEmpty
            ? d.value
            : '${d.field.replaceAll(':', '')} is ${negated ? 'not ' : ''}${d.value}');
    return Semantics(
      button: true,
      label: semantic,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: KuberMotion.fxFast,
          curve: KuberMotion.curveEffects,
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(KuberShape.small),
            border: Border.all(color: edge, width: width),
          ),
          // Center with widthFactor 1 keeps the chip as wide as its content
          // inside the Wrap (an aligned container would fill the row).
          child: Center(
            widthFactor: 1,
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (negated) ...[
                const NotLabel(),
                const SizedBox(width: 6),
              ],
              if (isWords) ...[
                Icon(Icons.format_quote_rounded,
                    size: 16,
                    color: selected ? cs.onPrimary : cs.tertiary),
                const SizedBox(width: 4),
              ],
              if (d != null && d.field.isNotEmpty)
                Text(
                  '${d.field} ',
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? cs.onPrimary : cs.primary,
                  ),
                ),
              Flexible(
                child: Text(
                  d?.value ?? item.text,
                  style: valueStyle,
                  softWrap: true,
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

/// The small "not" label (errorContainer, r4).
class NotLabel extends StatelessWidget {
  const NotLabel({super.key, this.highlight = false});
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'not',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: KuberMotion.fxFast,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: highlight ? cs.primary : cs.errorContainer,
          borderRadius: BorderRadius.circular(KuberShape.extraSmall),
        ),
        child: Text(
          'not',
          style: localeFont(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: highlight ? cs.onPrimary : cs.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

/// "and" / "or" between filters. Tap flips.
class JoinerChip extends StatelessWidget {
  const JoinerChip({
    super.key,
    required this.isOr,
    required this.selected,
    required this.onTap,
  });
  final bool isOr, selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final word = isOr ? 'or' : 'and';
    final l = context.l10n;
    return Semantics(
      button: onTap != null,
      label: onTap == null
          ? word
          : l.ahfJoinerSemantics(word, isOr ? 'and' : 'or'),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // 32 dp tap target around the 24 dp word pill (design `jn`).
        child: SizedBox(
          height: 32,
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: KuberMotion.fxFast,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: selected
                    ? cs.primary
                    : isOr
                        ? cs.onSecondaryContainer.withValues(alpha: 0.10)
                        : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                widthFactor: 1,
                child: AnimatedSwitcher(
                  duration: KuberMotion.fxInstant,
                  child: Text(
                    word,
                    key: ValueKey(word),
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? cs.onPrimary
                          : isOr
                              ? cs.onSecondaryContainer
                              : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A lone bracket: level 4+ inside a box, unmatched (error) or ghost.
class BracketToken extends StatelessWidget {
  const BracketToken({
    super.key,
    required this.open,
    this.error = false,
    this.ghost = false,
    this.selected = false,
  });
  final bool open, error, ghost, selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected
        ? cs.onPrimary
        : error
            ? cs.onErrorContainer
            : cs.onSurfaceVariant;
    final text = Text(
      open ? '(' : ')',
      style: monoFont(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
    );
    final box = AnimatedContainer(
      duration: KuberMotion.fxFast,
      height: 24,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: ghost
          ? null
          : BoxDecoration(
              color: selected
                  ? cs.primary
                  : error
                      ? cs.errorContainer
                      : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(KuberShape.extraSmall + 2),
              border: error ? Border.all(color: cs.error, width: 1.5) : null,
            ),
      child: Center(widthFactor: 1, child: text),
    );
    return Semantics(
      label: ghost
          ? context.l10n.ahfGhostBracketSemantics
          : open
              ? context.l10n.ahfBracketOpenSemantics
              : context.l10n.ahfBracketCloseSemantics,
      excludeSemantics: true,
      child: ghost
          ? CustomPaint(
              foregroundPainter: DashedBorderPainter(
                color: cs.outline.withValues(alpha: 0.6),
                radius: 6,
                strokeWidth: 1,
                dash: 3,
                gap: 3,
              ),
              child: Opacity(opacity: 0.6, child: box),
            )
          : box,
    );
  }
}
