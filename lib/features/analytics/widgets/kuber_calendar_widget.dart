import 'package:flutter/material.dart';
import '../../../shared/widgets/app_icon_button.dart';
import 'package:intl/intl.dart';

class KuberCalendarWidget extends StatefulWidget {
  final DateTime viewDate;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final ValueChanged<DateTime> onDateTapped;
  final VoidCallback onMonthPressed;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const KuberCalendarWidget({
    super.key,
    required this.viewDate,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onDateTapped,
    required this.onMonthPressed,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  State<KuberCalendarWidget> createState() => _KuberCalendarWidgetState();
}

class _KuberCalendarWidgetState extends State<KuberCalendarWidget> {
  bool _isBackwards = false;

  @override
  void didUpdateWidget(KuberCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewDate.isBefore(oldWidget.viewDate)) {
      _isBackwards = true;
    } else if (widget.viewDate.isAfter(oldWidget.viewDate)) {
      _isBackwards = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final daysInMonth = DateTime(
      widget.viewDate.year,
      widget.viewDate.month + 1,
      0,
    ).day;
    final firstDayWeekday = DateTime(
      widget.viewDate.year,
      widget.viewDate.month,
      1,
    ).weekday; // 1=Mon, 7=Sun
    final paddingDays = firstDayWeekday - 1;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200) {
          widget.onPrevMonth();
        } else if (details.primaryVelocity! < -200) {
          widget.onNextMonth();
        }
      },
      child: Column(
        children: [
          // Header: Month LEFT, Arrows RIGHT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onMonthPressed,
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(widget.viewDate),
                        style: tt.titleSmall?.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    AppIconButton(
                      icon: Icons.chevron_left_rounded,
                      kind: AppIconButtonKind.plain,
                      semanticLabel: 'Previous month',
                      onPressed: widget.onPrevMonth,
                    ),
                    AppIconButton(
                      icon: Icons.chevron_right_rounded,
                      kind: AppIconButtonKind.plain,
                      semanticLabel: 'Next month',
                      onPressed: widget.onNextMonth,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'].map((d) {
              return SizedBox(
                width: 40,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Days grid
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: Offset(_isBackwards ? -0.12 : 0.12, 0),
                    end: Offset.zero,
                  ),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: GridView.builder(
              key: ValueKey(widget.viewDate),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: 1.1, // Adjusted for height optimization
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayNumber = index - paddingDays + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox();
                }

                final date = DateTime(
                  widget.viewDate.year,
                  widget.viewDate.month,
                  dayNumber,
                );
                final isToday = date.isAtSameMomentAs(
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  ),
                );
                final isSelectedStart = date.isAtSameMomentAs(
                  widget.rangeStart,
                );
                final isSelectedEnd = date.isAtSameMomentAs(widget.rangeEnd);
                final isInRange =
                    date.isAfter(widget.rangeStart) &&
                    date.isBefore(widget.rangeEnd);
                final isFuture = date.isAfter(DateTime.now());

                return GestureDetector(
                  onTap: isFuture ? null : () => widget.onDateTapped(date),
                  child: Opacity(
                    opacity: isFuture ? 0.38 : 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isInRange || isSelectedStart || isSelectedEnd)
                          Container(
                            // secondaryContainer band; the caps sit on it.
                            margin: EdgeInsets.only(
                              left: isSelectedStart && !isSelectedEnd ? 20 : 0,
                              right: isSelectedEnd && !isSelectedStart ? 20 : 0,
                            ),
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelectedStart && isSelectedEnd
                                  ? null
                                  : cs.secondaryContainer,
                            ),
                          ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (isSelectedStart || isSelectedEnd)
                                ? cs.primary
                                : null,
                            shape: BoxShape.circle,
                            border:
                                isToday && !isSelectedStart && !isSelectedEnd
                                ? Border.all(color: cs.primary)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: tt.bodyLarge?.copyWith(
                              color: (isSelectedStart || isSelectedEnd)
                                  ? cs.onPrimary
                                  : isInRange
                                  ? cs.onSecondaryContainer
                                  : isFuture
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
