// Calendar day cell (upcoming-calendar-v1 §2): 48 × 54. A 36 dp number circle
// at top 2, a 10 dp dot row 4 below it (6 dp dots, gap 3, at most 3 then
// "+N"), the overdue badge top right. Dots always sit on surface.

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'event_row_bits.dart';

/// One dot: the event's type, drawn as a ring when skipped.
class DayDot {
  final String sourceType;
  final bool skipped;
  const DayDot(this.sourceType, {this.skipped = false});
}

class DayCellState {
  final int day;
  final bool today;
  final bool selected;
  final bool past;
  final bool otherMonth;
  final bool overdue;
  final List<DayDot> dots;
  const DayCellState({
    required this.day,
    this.today = false,
    this.selected = false,
    this.past = false,
    this.otherMonth = false,
    this.overdue = false,
    this.dots = const [],
  });
}

const double kDayCellHeight = 54;

class UpcomingDayCell extends StatelessWidget {
  final DayCellState state;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;

  const UpcomingDayCell({
    super.key,
    required this.state,
    this.semanticLabel,
    this.onTap,
    this.onLongPress,
    this.width = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = state;
    final emphasised = s.today || s.selected;
    final fg = s.otherMonth
        ? cs.onSurface.withValues(alpha: 0.38)
        : s.selected
            ? (s.today ? cs.primary : cs.onSecondaryContainer)
            : s.today
                ? cs.primary
                : s.past
                    ? cs.onSurfaceVariant
                    : cs.onSurface;
    final dots = s.otherMonth ? const <DayDot>[] : s.dots;
    final more = dots.length > 3 ? dots.length - 3 : 0;

    return Semantics(
      button: true,
      selected: s.selected,
      label: semanticLabel,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: kDayCellHeight,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(KuberShape.medium),
            overlayColor: WidgetStatePropertyAll(cs.onSurface.withValues(alpha: 0.10)),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 2),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.selected && !s.otherMonth ? cs.secondaryContainer : null,
                        border: s.today && !s.otherMonth
                            ? Border.all(color: cs.primary, width: s.selected ? 2 : 1)
                            : null,
                      ),
                      child: Text(
                        '${s.day}',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: fg,
                          fontWeight: emphasised && !s.otherMonth ? FontWeight.w700 : FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final (i, d) in dots.take(3).indexed) ...[
                            if (i > 0) const SizedBox(width: 3),
                            _Dot(d),
                          ],
                          if (more > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '+$more',
                              style: theme.textTheme.labelSmall!.copyWith(
                                fontSize: 11,
                                height: 10 / 11,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurfaceVariant,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (s.overdue && !s.otherMonth)
                  Positioned(
                    top: 0,
                    right: width / 2 - 24 + 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
                      child: Container(
                        width: 14,
                        height: 14,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: cs.error, shape: BoxShape.circle),
                        child: Icon(Icons.priority_high_rounded, size: 10, color: cs.onError),
                      ),
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

class _Dot extends StatelessWidget {
  final DayDot dot;
  const _Dot(this.dot);

  @override
  Widget build(BuildContext context) {
    final c = eventSourceStyle(context, dot.sourceType).color;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dot.skipped ? null : c,
        border: dot.skipped ? Border.all(color: c, width: 1.5) : null,
      ),
    );
  }
}
