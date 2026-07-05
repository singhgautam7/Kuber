import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../engine/event_aggregator.dart';
import '../providers/upcoming_events_provider.dart';
import '../widgets/event_row_bits.dart';

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
    final windowed =
        eventsWithinDays(eventsAsync.valueOrNull ?? const [], range);
    final events = sourceFilter == 'all'
        ? windowed
        : windowed.where((e) => e.sourceType == sourceFilter).toList();

    final groups = _group(events);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, showHome: true, showBrand: false),
      body: Column(
        children: [
          const KuberPageHeader(
            title: 'Upcoming events',
            description:
                'Everything coming up across reminders, EMIs, SIPs, and more',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: KuberSpacing.lg,
                right: KuberSpacing.lg,
                bottom: navBarBottomPadding(context),
              ),
              children: [
                _SourceChips(
                  selected: sourceFilter,
                  onSelected: (v) => ref
                      .read(upcomingEventsSourceFilterProvider.notifier)
                      .state = v,
                ),
                const SizedBox(height: 9),
                _RangeChips(
                  selected: range,
                  onSelected: (v) => ref
                      .read(upcomingEventsRangeProvider.notifier)
                      .state = v,
                ),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 64),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 36,
                              color: cs.onSurfaceVariant
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No upcoming events in the next $range days',
                            style: localeFont(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final group in groups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 16, 2, 9),
                      child: Text(
                        group.label,
                        style: localeFont(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    for (final event in group.events)
                      _EventCard(event: event),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<({String label, List<UpcomingEvent> events})> _group(
      List<UpcomingEvent> events) {
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
        'LATER'
      ])
        if (buckets.containsKey(label))
          (label: label, events: buckets[label]!),
    ];
  }
}

class _SourceChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _SourceChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const entries = [
      ('all', 'All'),
      ('reminder', 'Reminders'),
      ('emi', 'EMIs'),
      ('sip', 'SIPs'),
      ('recurring', 'Recurring'),
      ('ledger', 'Ledger'),
    ];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final (value, label) = entries[i];
          final active = value == selected;
          return GestureDetector(
            onTap: () => onSelected(value),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? cs.primary.withValues(alpha: 0.12)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(
                  color: active
                      ? cs.primary.withValues(alpha: 0.4)
                      : cs.outline,
                ),
              ),
              child: Text(
                label,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RangeChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _RangeChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const entries = [
      (7, 'Next 7 days'),
      (30, 'Next 30 days'),
      (90, 'Next 90 days'),
    ];
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final (value, label) = entries[i];
          final active = value == selected;
          return GestureDetector(
            onTap: () => onSelected(value),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: active ? cs.primary : cs.outline,
                ),
              ),
              child: Text(
                label,
                style: localeFont(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final UpcomingEvent event;

  const _EventCard({required this.event});

  String _timeLabel(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(event.date.year, event.date.month, event.date.day);
    final hasTime = event.date.hour != 0 || event.date.minute != 0;
    if (day == today && hasTime) {
      return DateFormat('h:mm a').format(event.date);
    }
    return DateFormat('d MMM').format(event.date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final amount = event.amount;

    return GestureDetector(
      onTap: () => openUpcomingEventSource(context, ref, event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      EventSourcePill(sourceType: event.sourceType),
                      const SizedBox(width: 6),
                      Text(
                        _timeLabel(context),
                        style: localeFont(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (amount != null) ...[
              const SizedBox(width: 11),
              Text(
                maskAmount(
                  '${amount >= 0 ? '+' : '−'}${fmt.formatCurrency(amount.abs())}',
                  isPrivate,
                ),
                style: localeFont(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: amount >= 0 ? cs.tertiary : cs.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
