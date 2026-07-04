import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../engine/event_aggregator.dart';
import '../providers/upcoming_events_provider.dart';
import 'event_row_bits.dart';

const int _kWidgetRowCount = 4;

/// Upcoming Events home widget (screens 3a timeline rows / 3c empty state).
/// Replaces the old Recurring widget; registered as
/// `upcoming_events_widget`.
class UpcomingEventsWidget extends ConsumerWidget {
  const UpcomingEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final all = eventsAsync.valueOrNull;
    if (all == null) return const SizedBox.shrink();
    final events = eventsWithinDays(all, 30);

    final visible = events.take(_kWidgetRowCount).toList();
    final moreCount = events.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberHomeWidgetTitle(
          title: 'Upcoming Events',
          trailing: Text(
            'Next 30 days',
            style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ),
        Container(
          padding: events.isEmpty
              ? const EdgeInsets.symmetric(vertical: 26, horizontal: 16)
              : const EdgeInsets.fromLTRB(14, 6, 14, 0),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: cs.outline),
          ),
          child: events.isEmpty
              ? Column(
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 28,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    Text(
                      'No upcoming events in the next 30 days',
                      textAlign: TextAlign.center,
                      style: localeFont(
                        fontSize: 12.5,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    for (var i = 0; i < visible.length; i++)
                      _EventTimelineRow(
                        event: visible[i],
                        showDivider:
                            i < visible.length - 1 || moreCount > 0,
                      ),
                    if (moreCount > 0)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            context.push('/more/upcoming-events'),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              '+ $moreCount more →',
                              style: localeFont(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Date-stub timeline row (3a): month + day on the left, vertical divider,
/// title + source pill, amount right-aligned.
class _EventTimelineRow extends ConsumerWidget {
  final UpcomingEvent event;
  final bool showDivider;

  const _EventTimelineRow({required this.event, required this.showDivider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final amount = event.amount;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openUpcomingEventSource(context, ref, event),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                      color: cs.outline.withValues(alpha: 0.6)))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(event.date).toUpperCase(),
                    style: localeFont(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${event.date.day}',
                    style: localeFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 26, color: cs.outline),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  EventSourcePill(sourceType: event.sourceType),
                ],
              ),
            ),
            if (amount != null) ...[
              const SizedBox(width: 8),
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
