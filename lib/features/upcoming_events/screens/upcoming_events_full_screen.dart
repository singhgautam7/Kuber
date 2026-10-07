import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../engine/event_aggregator.dart';
import '../providers/upcoming_events_provider.dart';
import '../widgets/upcoming_events_widget.dart';

/// Upcoming Events full-screen page (screen 3d). Universal landing pattern,
/// no FAB — a read-only aggregation, not a data source.
class UpcomingEventsFullScreen extends ConsumerWidget {
  const UpcomingEventsFullScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final range = ref.watch(upcomingEventsRangeProvider);
    final sourceFilter = ref.watch(upcomingEventsSourceFilterProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);
    // Both range and source are filtered client-side so switching chips is
    // instant (no provider re-subscription).
    final windowed = eventsWithinDays(
      eventsAsync.valueOrNull ?? const [],
      range,
    );
    final events = sourceFilter == 'all'
        ? windowed
        : windowed.where((e) => e.sourceType == sourceFilter).toList();

    final groups = _group(events);

    const sources = [
      ('all', 'All'),
      ('reminder', 'Reminders'),
      ('emi', 'EMIs'),
      ('sip', 'SIPs'),
      ('recurring', 'Recurring'),
      ('ledger', 'Ledger'),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: const KuberAppBar(title: 'Upcoming events', showBack: true),
        body: ListView(
          padding: EdgeInsets.only(bottom: navBarBottomPadding(context)),
          children: [
            // Range dropdown chip + type filter chips (board 3.26).
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                children: [
                  KuberDropdownChip<int>(
                    value: range,
                    options: const [
                      KuberDropdownOption(7, 'Next 7 days'),
                      KuberDropdownOption(30, 'Next 30 days'),
                      KuberDropdownOption(90, 'Next 90 days'),
                    ],
                    onChanged: (v) =>
                        ref.read(upcomingEventsRangeProvider.notifier).state =
                            v,
                  ),
                  for (final (value, label) in sources) ...[
                    const SizedBox(width: KuberSpace.sm),
                    KuberChip(
                      label: label,
                      selected: value == sourceFilter,
                      onTap: () =>
                          ref
                                  .read(
                                    upcomingEventsSourceFilterProvider.notifier,
                                  )
                                  .state =
                              value,
                    ),
                  ],
                ],
              ),
            ),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: KuberEmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'No upcoming events in the next $range days',
                  description:
                      'Reminders, EMIs, SIPs, recurring and ledger '
                      'dates show up here.',
                ),
              )
            else
              for (final group in groups)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin,
                    KuberSpace.lg,
                    KuberSpace.screenMargin,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KuberSectionHeader(title: group.label),
                      KuberGroup(
                        children: [
                          for (final event in group.events)
                            UpcomingEventRow(event: event),
                        ],
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  List<({String label, List<UpcomingEvent> events})> _group(
    List<UpcomingEvent> events,
  ) {
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
      for (final label in const [
        'TODAY',
        'TOMORROW',
        'THIS WEEK',
        'NEXT WEEK',
        'LATER',
      ])
        if (buckets.containsKey(label)) (label: label, events: buckets[label]!),
    ];
  }
}
