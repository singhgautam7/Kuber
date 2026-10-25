import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/overflow_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../engine/event_aggregator.dart';
import '../providers/upcoming_calendar_provider.dart';
import '../providers/upcoming_events_provider.dart';
import '../widgets/upcoming_calendar.dart';
import '../widgets/upcoming_events_widget.dart';
import '../widgets/upcoming_sheets.dart';

/// Upcoming events (screen 26, upcoming-calendar-v1): List and Calendar
/// behind one toolbar row (view dropdown chip + Filter chip). The choice is
/// saved; the type filter is shared by both views.
class UpcomingEventsFullScreen extends ConsumerWidget {
  const UpcomingEventsFullScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final view = ref.watch(upcomingCalendarViewProvider);
    final calendar = view.valueOrNull;
    if (calendar == null) return Scaffold(backgroundColor: cs.surface);
    final count = upcomingFilterCount(ref, calendar: calendar);

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KuberAppBar(
              title: l.ueTitle,
              showBack: true,
              // "How it works" lives in the overflow (round 5): in Calendar
              // it is the legend.
              overflowConfig: calendar
                  ? KuberOverflowConfig(items: [
                      KuberOverflowItem(
                        icon: Icons.help_outline_rounded,
                        label: l.ueLegendTitle,
                        onTap: () => showUpcomingLegendSheet(context),
                      ),
                    ])
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 4, KuberSpace.screenMargin, 12),
              child: Row(
                children: [
                  KuberDropdownChip<bool>(
                    value: calendar,
                    icon: calendar ? Icons.calendar_month_outlined : Icons.view_agenda_outlined,
                    options: [
                      KuberDropdownOption(false, l.ueViewList, icon: Icons.view_agenda_outlined),
                      KuberDropdownOption(true, l.ueViewCalendar, icon: Icons.calendar_month_outlined),
                    ],
                    onChanged: (v) => ref.read(upcomingCalendarViewProvider.notifier).setCalendar(v),
                  ),
                  const SizedBox(width: KuberSpace.sm),
                  Semantics(
                    label: count > 0 ? l.ueA11yFilter(count) : null,
                    child: KuberChip(
                      label: l.ueFilter,
                      icon: Icons.tune_rounded,
                      selected: count > 0,
                      showCheck: false,
                      badge: count > 0 ? '$count' : null,
                      onTap: () => showUpcomingFilterSheet(context, calendar: calendar),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _FadeThrough(
          calendar: calendar,
          child: calendar ? const UpcomingCalendarView(key: ValueKey('calendar')) : const _ListBody(key: ValueKey('list')),
        ),
      ),
    );
  }
}

/// View switch (motion.md): old content out in 90 ms, new content in over
/// 150 ms with a 0.96 → 1 scale from top centre. App bar and toolbar stay.
class _FadeThrough extends StatelessWidget {
  final bool calendar;
  final Widget child;
  const _FadeThrough({required this.calendar, required this.child});

  @override
  Widget build(BuildContext context) {
    final reduced = KuberMotion.reduced(context);
    return AnimatedSwitcher(
      duration: reduced ? KuberMotion.instant : const Duration(milliseconds: 240),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) {
        if (reduced) return FadeTransition(opacity: animation, child: child);
        final incoming = child.key == this.child.key;
        if (!incoming) {
          // Reverse animation runs 1 → 0: gone within the first 90 ms.
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: const Interval(0.625, 1)),
            child: child,
          );
        }
        final a = CurvedAnimation(parent: animation, curve: const Interval(0.375, 1, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: a,
          child: ScaleTransition(
            alignment: Alignment.topCenter,
            scale: Tween(begin: 0.96, end: 1.0).animate(a),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ListBody extends ConsumerWidget {
  const _ListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final range = ref.watch(upcomingEventsRangeProvider);
    final sourceFilter = ref.watch(upcomingEventsSourceFilterProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);
    // Both range and source are filtered client-side so switching is instant
    // (no provider re-subscription).
    final windowed = eventsWithinDays(eventsAsync.valueOrNull ?? const [], range);
    final events =
        sourceFilter == 'all' ? windowed : windowed.where((e) => e.sourceType == sourceFilter).toList();
    final groups = _group(events);

    return ListView(
      padding: EdgeInsets.only(bottom: navBarBottomPadding(context)),
      children: [
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: KuberEmptyState(
              icon: Icons.event_available_outlined,
              title: l.ueEmptyList(range),
              description: l.ueEmptyListHint,
            ),
          )
        else
          for (final group in groups)
            Padding(
              padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, KuberSpace.lg, KuberSpace.screenMargin, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KuberSectionHeader(title: group.label),
                  KuberGroup(
                    children: [
                      for (final event in group.events) UpcomingEventRow(event: event),
                    ],
                  ),
                ],
              ),
            ),
      ],
    );
  }

  List<({String label, List<UpcomingEvent> events})> _group(List<UpcomingEvent> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));
    final weekEnd = today.add(Duration(days: 8 - today.weekday));
    final nextWeekEnd = weekEnd.add(const Duration(days: 7));

    final buckets = <String, List<UpcomingEvent>>{};
    for (final e in events) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      final String label;
      if (day == today) {
        label = 'TODAY';
      } else if (day == tomorrow && dayAfter.isBefore(weekEnd)) {
        label = 'TOMORROW';
      } else if (day.isBefore(weekEnd)) {
        label = 'THIS WEEK';
      } else if (day.isBefore(nextWeekEnd)) {
        label = 'NEXT WEEK';
      } else {
        label = 'LATER';
      }
      buckets.putIfAbsent(label, () => []).add(e);
    }

    return [
      for (final label in const ['TODAY', 'TOMORROW', 'THIS WEEK', 'NEXT WEEK', 'LATER'])
        if (buckets.containsKey(label)) (label: label, events: buckets[label]!),
    ];
  }
}
