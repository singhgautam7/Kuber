// Rule sheet -> full screen (design R.4): what a rule costs per month and every
// transaction it created, plus Edit / Pause / Skip next / Delete.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/background/background_run_controller.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/money_bar_chart.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../shared/widgets/when_picker.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/transaction_row.dart';
import '../data/recurring_rule.dart';
import '../domain/recurring_service.dart';
import '../providers/recurring_hub_provider.dart';
import '../providers/recurring_provider.dart';

void showRuleSheet(BuildContext context, WidgetRef ref, RecurringRule rule) =>
    showMoneySheet<void>(context, RuleSheet(rule: rule));

Future<void> confirmDeleteRule(BuildContext context, WidgetRef ref, RecurringRule rule) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  final l = context.l10n;
  final cs = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.msRecDeleteTitle(rule.name), style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(l.msRecDeleteBody, style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.deleteLabel, style: TextStyle(color: cs.error)),
        ),
      ],
    ),
  );
  if (ok != true) return;
  await RecurringService(container.read(isarProvider)).delete(rule);
  container.invalidate(recurringListProvider);
}

/// Skip next with the "Skipped 1 Jan. Next on 1 Apr." + Undo snackbar.
Future<void> skipNextOccurrence(BuildContext context, WidgetRef ref, RecurringRule rule) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  // The snackbar goes on the app, not the closed sheet.
  final host = Navigator.of(context, rootNavigator: true).context;
  if (blockIfProcessing(context, ref, 'recurring:${rule.id}')) return;
  final l = context.l10n;
  final service = RecurringService(container.read(isarProvider));
  final day = await service.skip(rule);
  container.invalidate(recurringListProvider);
  if (day == null || !host.mounted) return;
  final next = nextDate(rule.schedule!, fromKey: addDays(day, 1));
  showKuberSnackBar(
    host,
    next == null
        ? l.msRecSkippedEnd(fmtDayShort(dayOf(day)))
        : l.msRecSkipped(fmtDayShort(dayOf(day)), fmtDayShort(dayOf(next))),
    actionLabel: l.msRecUndo,
    onAction: () async {
      await service.undoSkip(rule, day);
      container.invalidate(recurringListProvider);
    },
  );
}

Future<void> togglePauseRule(BuildContext context, WidgetRef ref, RecurringRule rule) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  // The snackbar goes on the app, not the closed sheet.
  final host = Navigator.of(context, rootNavigator: true).context;
  if (blockIfProcessing(context, ref, 'recurring:${rule.id}')) return;
  final l = context.l10n;
  final pausing = !rule.schedule!.paused;
  await RecurringService(container.read(isarProvider)).setPaused(rule, pausing);
  container.invalidate(recurringListProvider);
  if (!host.mounted) return;
  final next = nextDate(rule.schedule!);
  showKuberSnackBar(
      host,
      pausing
          ? l.msRecPausedSnack(rule.name)
          : l.msRecResumedSnack(rule.name, next == null ? '' : fmtDayShort(dayOf(next))));
}

void editRule(BuildContext context, WidgetRef ref, RecurringRule rule) {
  if (blockIfProcessing(context, ref, 'recurring:${rule.id}')) return;
  context.push('/recurring/edit', extra: rule);
}

class RuleSheet extends ConsumerWidget {
  final RecurringRule rule;
  const RuleSheet({super.key, required this.rule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final cat = ref.watch(categoryMapProvider).valueOrNull?[int.tryParse(rule.categoryId)];
    final acc = ref.watch(accountMapProvider).valueOrNull?[int.tryParse(rule.accountId)];
    final history = ref.watch(ruleHistoryProvider(rule.id)).valueOrNull;
    final s = rule.schedule!;
    final ended = isEnded(s);
    final income = rule.type == 'income';
    final nav = Navigator.of(context);
    return MoneySummarySheet(
      contextLabel: intervalText(l, s.intervalCount, s.intervalUnit),
      title: rule.name,
      leading: cat == null
          ? null
          : CategoryIcon.square(icon: IconMapper.fromString(cat.icon), rawColor: Color(cat.colorValue), size: 48),
      body: [
        MoneyHeadline(
          label: l.msRecUsually,
          value: '${income ? '+' : '-'}${fmt.formatCurrency(rule.amount)}',
          color: income ? money.income : money.expense,
        ),
        if (!ended) WhenPreview(value: WhenValue.fromSchedule(s)),
        KvGrid(items: [
          KvItem(l.msRecLast12, fmt.formatCurrency((history?.last12 ?? 0).round())),
          KvItem(l.msRecMonthlyAvg, fmt.formatCurrency((history?.avg ?? 0).round())),
          KvItem(l.msRecProcessedKv, l.msRecProcessedN('${s.postedCount}')),
        ]),
        KuberGroup(children: [
          KuberListRow(title: acc?.name ?? '-', subtitle: l.msRecAccount, dense: true),
          KuberListRow(title: cat?.name ?? '-', subtitle: l.msRecCategory, dense: true),
        ]),
      ],
      actions: ended
          ? [
              SheetAction(
                  label: l.deleteLabel,
                  icon: Icons.delete_outline_rounded,
                  destructive: true,
                  onPressed: () {
                    nav.pop();
                    confirmDeleteRule(context, ref, rule);
                  }),
            ]
          : [
              SheetAction(
                  label: l.editLabel,
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    nav.pop();
                    editRule(context, ref, rule);
                  }),
              SheetAction(
                  label: s.paused ? l.msRecResume : l.msRecPause,
                  icon: s.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  onPressed: () {
                    nav.pop();
                    togglePauseRule(context, ref, rule);
                  }),
              SheetAction(
                  label: l.msRecSkipNextShort,
                  icon: Icons.skip_next_rounded,
                  onPressed: () {
                    nav.pop();
                    skipNextOccurrence(context, ref, rule);
                  }),
              SheetAction(
                  label: l.deleteLabel,
                  icon: Icons.delete_outline_rounded,
                  destructive: true,
                  onPressed: () {
                    nav.pop();
                    confirmDeleteRule(context, ref, rule);
                  }),
            ],
      details: (_) => RuleFullScreen(rule: rule),
    );
  }
}

class RuleFullScreen extends ConsumerStatefulWidget {
  final RecurringRule rule;
  const RuleFullScreen({super.key, required this.rule});

  @override
  ConsumerState<RuleFullScreen> createState() => _RuleFullScreenState();
}

class _RuleFullScreenState extends ConsumerState<RuleFullScreen> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final rule = widget.rule;
    final s = rule.schedule!;
    final history = ref.watch(ruleHistoryProvider(rule.id)).valueOrNull;
    final cat = ref.watch(categoryMapProvider).valueOrNull?[int.tryParse(rule.categoryId)];
    final cats = ref.watch(categoryMapProvider).valueOrNull ?? const {};
    final accounts = ref.watch(accountMapProvider).valueOrNull ?? const {};
    final monthly = history?.monthly ?? const [];
    final bars = _all ? _allMonths(history) : monthly;
    final skipped = s.skippedDates.where((d) => d <= s.processedThrough).toList()..sort();
    return MoneyFullScreen(
      title: rule.name,
      overflow: [
        PopupMenuItem(value: () => editRule(context, ref, rule), child: Text(l.editLabel)),
        PopupMenuItem(
            value: () => confirmDeleteRule(context, ref, rule).then((_) {
                  if (context.mounted) Navigator.of(context).pop();
                }),
            child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
      ],
      identity: MoneyIdentity(
        tile: cat == null
            ? const KuberIconTile(icon: Icons.repeat_rounded, size: 48)
            : CategoryIcon.square(icon: IconMapper.fromString(cat.icon), rawColor: Color(cat.colorValue), size: 48),
        contextLabel: scheduleSentence(l, s),
        headline: fmt.formatCurrency((history?.last12 ?? 0).round()),
        caption: l.msRecAvgCaption(fmt.formatCurrency((history?.avg ?? 0).round())),
      ),
      chart: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(l.msRecMonthlyTotal, style: tt.titleSmall)),
          ChoiceChip(
            label: Text(_all ? l.msRecRangeAll : l.msRecRange12),
            selected: true,
            onSelected: (_) => setState(() => _all = !_all),
          ),
        ]),
        const SizedBox(height: 16),
        MoneyBarChart(
          bars: [
            for (final m in bars) MoneyBar(DateFormat('MMM', AppLocale.current.languageCode).format(m.$1), [m.$2])
          ],
          colors: [rule.type == 'income' ? context.kuberMoney.income : cs.primary],
          selected: bars.isEmpty ? null : bars.length - 1,
        ),
      ]),
      list: [
        KuberSectionHeader(title: l.msRecProcessedKv),
        if (history != null && history.transactions.isNotEmpty)
          TransactionDayCard(
            transactions: history.transactions,
            onTap: (t) => showTransactionDetailSheet(context, ref, t),
            onEdit: (t) => context.push('/add-transaction', extra: t),
            onDelete: (t) => deleteTransactionWithUndo(context, ref, t),
            formatter: fmt,
            categoryMap: cats,
            accountMap: accounts,
          ),
        if (skipped.isNotEmpty) ...[
          const SizedBox(height: 12),
          KuberGroup(children: [
            for (final d in skipped.reversed)
              KuberListRow(
                leading: const KuberIconTile(icon: Icons.skip_next_rounded, tone: KuberTone.neutral),
                title: l.msRecSkippedRow,
                subtitle: fmtDayLong(dayOf(d)),
              ),
          ]),
        ],
      ],
    );
  }

  List<(DateTime, double)> _allMonths(RuleHistory? h) {
    if (h == null || h.transactions.isEmpty) return const [];
    final first = h.transactions.last.createdAt;
    final now = DateTime.now();
    final out = <(DateTime, double)>[];
    for (var m = DateTime(first.year, first.month); !m.isAfter(now); m = DateTime(m.year, m.month + 1)) {
      out.add((
        m,
        h.transactions
            .where((t) => t.createdAt.year == m.year && t.createdAt.month == m.month)
            .fold(0.0, (s, t) => s + t.amount)
      ));
    }
    return out;
  }
}
