import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../../../core/utils/l10n_ext.dart';
import '../engine/event_aggregator.dart';
import '../engine/occurrences.dart';
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

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberHomeWidgetTitle(
          title: 'Upcoming Events',
          trailing: Text(
            'Next 30 days',
            style: theme.textTheme.bodySmall!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        if (events.isEmpty)
          KuberCard(
            child: Column(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 24,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(height: KuberSpace.sm),
                Text(
                  'No upcoming events in the next 30 days',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          // Grouped list, date block lead (board 3.2a).
          KuberGroup(
            children: [
              for (final e in visible) UpcomingEventRow(event: e),
              if (moreCount > 0)
                InkWell(
                  onTap: () => context.push('/more/upcoming-events'),
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        '+ $moreCount more →',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Event row (List, home widget, calendar day list). List: 40 date block,
/// title + type pill, amount. Calendar ([occurrence] given, design §3): type
/// tile instead of the date block (the date is in the day header), a status
/// pill, the card bill amount, skipped amounts struck through.
class UpcomingEventRow extends ConsumerWidget {
  final UpcomingEvent event;
  final CalendarOccurrence? occurrence;

  const UpcomingEventRow({super.key, required this.event, this.occurrence});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final o = occurrence;
    final ev = event;
    final isUrgent = ev is CreditCardEvent && ev.isUrgent;

    if (o != null) {
      final l = context.l10n;
      final (label, tone) = switch (o.status) {
        OccurrenceStatus.upcoming => (l.ueStatusUpcoming, KuberTone.neutral),
        OccurrenceStatus.needsConfirmation => (l.ueStatusConfirm, KuberTone.warning),
        OccurrenceStatus.done => (l.ueStatusDone, KuberTone.income),
        OccurrenceStatus.skipped => (l.ueStatusSkipped, KuberTone.neutral),
        OccurrenceStatus.overdue => (l.ueStatusOverdue, KuberTone.error),
      };
      final amount = o.isCardDue ? (o.cardBill == null ? null : -o.cardBill!) : o.amount;
      final skipped = o.status == OccurrenceStatus.skipped;
      final incoming = amount != null && amount > 0;
      return KuberListRow(
        onTap: () => openUpcomingEventSource(context, ref, event),
        minHeight: 88,
        leading: EventTypeTile(sourceType: event.sourceType),
        title: event.title,
        subtitle: eventSourceStyle(context, event.sourceType, fd: event is InvestmentMaturityEvent).label,
        below: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(alignment: Alignment.centerLeft, child: KuberPill(label: label, tone: tone)),
        ),
        trailing: amount == null
            ? null
            : Text(
                maskAmount('${incoming ? '+' : ''}${fmt.formatCurrency(amount.abs())}', isPrivate),
                style: theme.textTheme.titleMedium!.copyWith(
                  color: skipped
                      ? cs.onSurfaceVariant
                      : incoming && !isPrivate
                          ? context.kuberMoney.income
                          : cs.onSurface,
                  decoration: skipped ? TextDecoration.lineThrough : null,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
      );
    }

    final amount = event.amount;
    return KuberListRow(
      onTap: () => openUpcomingEventSource(context, ref, event),
      minHeight: KuberSpace.listItem2,
      leading: SizedBox(
        width: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMM').format(event.date).toUpperCase(),
              style: theme.textTheme.labelSmall!.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              '${event.date.day}',
              style: theme.textTheme.titleMedium!.copyWith(
                color: isUrgent ? context.kuberMoney.warning : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
      title: event.title,
      below: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: EventSourcePill(
            sourceType: event.sourceType, fd: event is InvestmentMaturityEvent),
      ),
      trailing: amount == null
          ? null
          : Text(
              maskAmount(
                '${amount >= 0 ? '+' : '−'}${fmt.formatCurrency(amount.abs())}',
                isPrivate,
              ),
              style: theme.textTheme.titleSmall!.copyWith(
                color: amount >= 0
                    ? context.kuberMoney.income
                    : context.kuberMoney.expense,
              ),
            ),
    );
  }
}
