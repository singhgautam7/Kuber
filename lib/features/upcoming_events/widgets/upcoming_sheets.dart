// Upcoming events sheets (upcoming-calendar-v1 §1, §4): Filter (range in
// List, type in both views) and the calendar legend.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../providers/upcoming_events_provider.dart';
import 'event_row_bits.dart';
import 'upcoming_day_cell.dart';

/// How many filters differ from the defaults (Next 30 days, All). The
/// Calendar has no range.
int upcomingFilterCount(WidgetRef ref, {required bool calendar}) {
  final type = ref.watch(upcomingEventsSourceFilterProvider);
  final range = ref.watch(upcomingEventsRangeProvider);
  return (type == 'all' ? 0 : 1) + (!calendar && range != 30 ? 1 : 0);
}

String upcomingTypeLabel(BuildContext context, String type) {
  final l = context.l10n;
  return switch (type) {
    'reminder' => l.ueTypeReminders,
    'emi' => l.ueTypeEmis,
    'sip' => l.ueTypeSips,
    'recurring' => l.ueTypeRecurring,
    'ledger' => l.ueTypeLedger,
    _ => l.ueTypeAll,
  };
}

Future<void> showUpcomingFilterSheet(BuildContext context, {required bool calendar}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FilterSheet(calendar: calendar),
  );
}

class _FilterSheet extends ConsumerWidget {
  final bool calendar;
  const _FilterSheet({required this.calendar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final type = ref.watch(upcomingEventsSourceFilterProvider);
    final range = ref.watch(upcomingEventsRangeProvider);
    void setType(String v) => ref.read(upcomingEventsSourceFilterProvider.notifier).state = v;
    void setRange(int v) => ref.read(upcomingEventsRangeProvider.notifier).state = v;

    return KuberBottomSheet(
      title: l.ueFilter,
      actions: calendar
          ? null
          : Row(children: [
              TextButton(
                onPressed: () {
                  setRange(30);
                  setType('all');
                },
                child: Text(l.ueFilterReset),
              ),
            ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!calendar) ...[
            KuberSectionHeader(title: l.ueFilterShow),
            Wrap(
              spacing: KuberSpace.sm,
              runSpacing: KuberSpace.sm,
              children: [
                for (final (days, label) in [(7, l.ueRange7), (30, l.ueRange30), (90, l.ueRange90)])
                  KuberChip(label: label, selected: range == days, onTap: () => setRange(days)),
              ],
            ),
            const SizedBox(height: KuberSpace.lg),
          ],
          KuberSectionHeader(title: l.ueFilterType),
          Padding(
            padding: const EdgeInsets.only(bottom: KuberSpace.sm),
            child: Text(l.ueFilterHint,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ),
          KuberGroup(
            children: [
              for (final t in ['all', ...kUpcomingTypes.where((t) => t != 'creditCard')])
                KuberListRow(
                  minHeight: 56,
                  dense: true,
                  selected: t == type,
                  leading: t == 'all'
                      ? const KuberIconTile(icon: Icons.filter_list_rounded, tone: KuberTone.neutral)
                      : EventTypeTile(sourceType: t),
                  title: upcomingTypeLabel(context, t),
                  trailing: Icon(
                    t == type ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: t == type ? cs.primary : cs.onSurfaceVariant,
                  ),
                  onTap: () => setType(t),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "About the calendar": dot colours, day states, how totals add up.
Future<void> showUpcomingLegendSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheet) {
      final l = sheet.l10n;
      final tt = Theme.of(sheet).textTheme;
      final cs = Theme.of(sheet).colorScheme;
      String label(String t) => switch (t) {
            'reminder' => l.ueLegendReminders,
            'emi' => l.ueLegendEmis,
            'sip' => l.ueLegendSips,
            'recurring' => l.ueLegendRecurring,
            'ledger' => l.ueLegendLedger,
            _ => l.ueLegendCards,
          };
      Widget mini(DayCellState s, String text) => SizedBox(
            width: 64,
            child: Column(children: [
              UpcomingDayCell(state: s),
              const SizedBox(height: KuberSpace.xs),
              Text(text, textAlign: TextAlign.center, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ]),
          );
      return KuberBottomSheet(
        title: l.ueLegendTitle,
        actions: AppButton(
          label: l.gotIt,
          type: AppButtonType.normal,
          fullWidth: true,
          onPressed: () => Navigator.of(sheet).pop(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.ueLegendIntro, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: KuberSpace.lg),
            KuberGroup(children: [
              for (final t in kUpcomingTypes)
                KuberListRow(
                  minHeight: 56,
                  dense: true,
                  leading: EventTypeTile(sourceType: t),
                  title: label(t),
                  trailing: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: eventSourceStyle(sheet, t).color, shape: BoxShape.circle),
                  ),
                ),
            ]),
            const SizedBox(height: KuberSpace.lg),
            KuberSectionHeader(title: l.ueLegendDays),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: KuberSpace.md,
              children: [
                mini(const DayCellState(day: 12, today: true), l.ueLegendToday),
                mini(const DayCellState(day: 5, selected: true), l.ueLegendSelected),
                mini(const DayCellState(day: 8, past: true, dots: [DayDot('reminder')], overdue: true),
                    l.ueLegendOverdue),
                mini(const DayCellState(day: 7, past: true, dots: [DayDot('recurring', skipped: true)]),
                    l.ueLegendSkipped),
                mini(const DayCellState(day: 1, otherMonth: true), l.ueLegendOtherMonth),
              ],
            ),
            const SizedBox(height: KuberSpace.lg),
            Text(l.ueLegendTotals, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    },
  );
}
