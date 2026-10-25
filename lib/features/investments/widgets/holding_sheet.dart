// Holding sheet -> full screen (design I.3) and its actions: update value,
// add money, past value, withdraw / close (I.5), FD early withdrawal.

import '../../categories/providers/category_provider.dart';
import '../../../shared/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/background/background_run_controller.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/money_math/investment_math.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tools/engine/fd_rd_engine.dart' show CompoundingFrequency;
import '../../tools/widgets/calculator_line_chart.dart';
import '../../tools/widgets/calculator_support.dart' show CalculatorPrefill;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/entity_picker_rows.dart';
import '../data/investment.dart';
import '../domain/investment_engine.dart';
import '../domain/investment_service.dart';
import '../providers/investment_provider.dart';

final investmentTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, uid) async {
  final all = await ref.watch(transactionListProvider.future);
  return all.where((t) => t.linkedRuleType == 'investment' && t.linkedRuleId == uid).toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
});

void showHoldingSheet(BuildContext context, WidgetRef ref, Investment i) =>
    showMoneySheet<void>(context, HoldingSheet(investment: i));

String investmentTypeLabel(BuildContext context, String t) {
  final l = context.l10n;
  return switch (t) {
    'mutual_fund' || 'sip' => l.msInvTypeMutualFund,
    'stocks' => l.msInvTypeStocks,
    'etf' => l.msInvTypeEtf,
    'gold' => l.msInvTypeGold,
    'crypto' => l.msInvTypeCrypto,
    'fd' => l.msInvTypeFd,
    'rd' => l.msInvTypeRd,
    'ppf' => l.msInvTypePpf,
    'bonds' => l.msInvTypeBonds,
    'real_estate' => l.msInvTypeProperty,
    'collectible' => l.msInvTypeCollectibles,
    _ => l.msInvTypeCustom,
  };
}

/// A holding's icon, drawn like a category (tinted square, filled glyph) in
/// its category's colour, the same as recurring rows.
class HoldingIcon extends ConsumerWidget {
  final Investment investment;
  final double size;
  const HoldingIcon(this.investment, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(categoryMapProvider).valueOrNull?[int.tryParse(investment.categoryId)];
    return CategoryIcon.square(
      icon: investmentIcon(investment.investmentType),
      rawColor: Color(cat?.colorValue ?? 0xFF26A69A),
      size: size,
    );
  }
}

IconData investmentIcon(String t) => switch (t) {
      'mutual_fund' || 'sip' || 'etf' => Icons.pie_chart_rounded,
      'stocks' => Icons.show_chart_rounded,
      'gold' => Icons.workspace_premium_rounded,
      'crypto' => Icons.currency_bitcoin_rounded,
      'fd' || 'rd' || 'ppf' || 'bonds' => Icons.savings_rounded,
      'real_estate' => Icons.home_work_rounded,
      _ => Icons.category_rounded,
    };

String compoundingLabel(BuildContext context, CompoundingFrequency f) {
  final l = context.l10n;
  return switch (f) {
    CompoundingFrequency.monthly => l.msInvCompMonthly,
    CompoundingFrequency.quarterly => l.msInvCompQuarterly,
    CompoundingFrequency.halfYearly => l.msInvCompHalfYearly,
    CompoundingFrequency.yearly => l.msInvCompYearly,
  };
}

Future<bool> confirmDeleteInvestment(BuildContext context, WidgetRef ref, Investment i) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  final l = context.l10n;
  final cs = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.deleteInvestmentConfirm, style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(l.deleteInvestmentBody, style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
      ],
    ),
  );
  if (ok != true) return false;
  await container.read(investmentListProvider.notifier).deleteInvestment(i);
  return true;
}

List<CalculatorLink> investmentCalculatorLinks(BuildContext context, Investment i) {
  final l = context.l10n;
  void open(String route, Map<String, dynamic> inputs) {
    Navigator.of(context, rootNavigator: true).maybePop();
    context.push('/more/tools/$route', extra: CalculatorPrefill(i.name, inputs));
  }

  final value = currentValue(i).round();
  if (hasFixedTerms(i)) {
    if (isPpf(i)) {
      return [
        CalculatorLink(l.msCalcPpf, () => open('ppf-calculator', {
              'deposit': '${(i.installment ?? i.fixedPrincipal ?? 0).round()}',
              'rate': '${i.fixedRate}',
            })),
      ];
    }
    return [
      CalculatorLink(l.msCalcFdRd, () => open('fd-rd-calculator', {
            'amount': '${(isRd(i) ? i.installment : i.fixedPrincipal)?.round()}',
            'rate': '${i.fixedRate}',
            'tenure': '${((i.fixedTenureMonths ?? 12) / 12).ceil()}',
            'type': isRd(i) ? 1 : 0,
            'freq': CompoundingFrequency.values.indexOf(i.compounding).clamp(0, 3),
          })),
    ];
  }
  if (i.behaviour != InvestmentBehaviour.market) return const [];
  return [
    CalculatorLink(l.msCalcSipAmount, () => open('sip-amount-finder', {'target': '', 'rate': '12', 'tenure': ''})),
    CalculatorLink(l.msCalcGoal, () => open('goal-planner', {'savings': '$value'})),
    CalculatorLink(l.msCalcReturns, () => open('sip-calculator', {
          'amount': '${(i.sipAmount ?? investedOf(i)).round()}',
          'rate': '12',
          'tenure': '10',
          'type': i.sip != null ? 1 : 0,
        })),
    CalculatorLink(l.msCalcInflation, () => open('inflation-calculator', {'amount': '$value'})),
  ];
}

class HoldingSheet extends ConsumerWidget {
  final Investment investment;
  const HoldingSheet({super.key, required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final i = investment;
    final txns = ref.watch(investmentTransactionsProvider(i.uid)).valueOrNull ?? const [];
    String m(num v) => fmt.formatCurrency(v.round());
    final nav = Navigator.of(context);
    final value = currentValue(i);
    final invested = investedOf(i);
    final gain = value - invested;
    final fixed = hasFixedTerms(i);
    final closed = i.status == InvestmentStatus.closed;
    final xirr = xirrOf(i, txns);
    final realized = realizedGainOf(i);
    Color gainColor(double g) => g >= 0 ? money.income : money.expense;
    String signed(double g) => '${g >= 0 ? '+' : '-'}${m(g.abs())}';

    final body = <Widget>[];
    if (fixed) {
      final maturity = maturityDateOf(i);
      final total = maturity == null ? 1 : maturity.difference(i.fixedStart!).inDays;
      final elapsed = DateTime.now().difference(i.fixedStart!).inDays;
      body.addAll([
        MoneyHeadline(
          label: l.msInvValueToday,
          value: m(value),
          labelTrailing: Row(mainAxisSize: MainAxisSize.min, children: [
            KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.accrued)),
            KuberCalculatedPill(l.msCalculated),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          KuberLinearProgress(value: total <= 0 ? 1 : elapsed / total),
          const SizedBox(height: 6),
          if (maturity != null)
            Text(l.msInvMatures(fmtDayLong(maturity)), style: Theme.of(context).textTheme.bodySmall),
        ]),
        KvGrid(items: [
          KvItem(l.msInvAtMaturity, m(maturityValue(i) ?? value)),
          KvItem(l.msInvRate, fmt.formatPercentage(i.fixedRate ?? 0)),
          KvItem(l.msInvCompounding, compoundingLabel(context, i.compounding)),
        ]),
      ]);
    } else {
      body.addAll([
        MoneyHeadline(label: l.msInvCurrentValue, value: m(value)),
        KvGrid(items: [
          KvItem(l.msInvInvested, m(invested)),
          KvItem(l.msInvUnrealized, signed(gain),
              valueColor: gainColor(gain), onInfo: () => showMoneyInfo(context, ref, MoneyInfo.realized)),
          KvItem(l.msInvXirr, xirr == null ? '-' : fmt.formatPercentage(xirr * 100),
              onInfo: () => showMoneyInfo(context, ref, MoneyInfo.xirr)),
          if (i.withdrawals.isNotEmpty) ...[
            KvItem(l.msInvRealized, signed(realized),
                valueColor: gainColor(realized), onInfo: () => showMoneyInfo(context, ref, MoneyInfo.realized)),
            KvItem(l.msInvWithdrawn, m(withdrawnOf(i))),
          ],
        ]),
        KuberGroup(children: [
          if (i.sip != null && nextSip(i) != null)
            KuberListRow(
              dense: true,
              title: i.stepUpValue > 0
                  ? l.msInvSipLineStep(m(nextSip(i)!.amount), ordinalFor(i.sip!.anchorDay ?? 1),
                      i.stepUpKind == StepUpKind.percent ? fmt.formatPercentage(i.stepUpValue) : m(i.stepUpValue))
                  : l.msInvSipLine(m(nextSip(i)!.amount), ordinalFor(i.sip!.anchorDay ?? 1)),
              subtitle: l.msInvSip,
            ),
          KuberListRow(
            dense: true,
            title: lastValueDate(i) == null ? '-' : fmtDayLong(lastValueDate(i)!),
            subtitle: l.msInvLastUpdated,
            trailing: KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.updated)),
          ),
        ]),
      ]);
    }
    final links = investmentCalculatorLinks(context, i);
    if (links.isNotEmpty) body.add(CalculatorLinkChips(links: links));

    SheetAction edit() => SheetAction(
        label: l.editLabel,
        icon: Icons.edit_outlined,
        onPressed: () {
          nav.pop();
          if (blockIfProcessing(context, ref, 'investment:${i.uid}')) return;
          context.push('/investments/edit', extra: i);
        });
    SheetAction delete() => SheetAction(
        label: l.deleteLabel,
        icon: Icons.delete_outline_rounded,
        destructive: true,
        onPressed: () {
          nav.pop();
          confirmDeleteInvestment(context, ref, i);
        });
    return MoneySummarySheet(
      contextLabel: investmentTypeLabel(context, i.investmentType),
      title: i.name,
      leading: HoldingIcon(i, size: 48),
      body: body,
      primary: closed
          ? null
          : fixed
              ? SheetAction(
                  label: l.msInvWithdrawEarly,
                  icon: Icons.output_rounded,
                  onPressed: () {
                    nav.pop();
                    showWithdrawSheet(context, ref, i);
                  })
              : SheetAction(
                  label: l.msInvUpdateValue,
                  icon: Icons.edit_note_rounded,
                  onPressed: () {
                    nav.pop();
                    showValueSheet(context, ref, i);
                  }),
      actions: closed
          ? [delete()]
          : fixed
              ? [edit(), delete()]
              : [
                  SheetAction(
                      label: l.msInvAddMoney,
                      icon: Icons.add_rounded,
                      onPressed: () {
                        nav.pop();
                        showAddMoneySheet(context, ref, i);
                      }),
                  SheetAction(
                      label: l.msInvWithdraw,
                      icon: Icons.output_rounded,
                      onPressed: () {
                        nav.pop();
                        showWithdrawSheet(context, ref, i);
                      }),
                  edit(),
                  delete(),
                ],
      details: (_) => HoldingFullScreen(investment: i),
    );
  }
}

// ── Full screen ─────────────────────────────────────────────────────────

enum _Range { year1, year2, all }

class HoldingFullScreen extends ConsumerStatefulWidget {
  final Investment investment;
  const HoldingFullScreen({super.key, required this.investment});

  @override
  ConsumerState<HoldingFullScreen> createState() => _HoldingFullScreenState();
}

class _HoldingFullScreenState extends ConsumerState<HoldingFullScreen> {
  _Range _range = _Range.all;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final i = ref.watch(investmentListProvider).valueOrNull?.where((x) => x.uid == widget.investment.uid).firstOrNull ??
        widget.investment;
    final txns = ref.watch(investmentTransactionsProvider(i.uid)).valueOrNull ?? const [];
    String m(num v) => fmt.formatCurrency(v.round());
    final fixed = hasFixedTerms(i);
    final value = currentValue(i);
    final invested = investedOf(i);
    final gain = value - invested;
    final xirr = xirrOf(i, txns);

    // Chart: month-end points from the start (or the range) to today.
    final now = DateTime.now();
    final start = switch (_range) {
      _Range.year1 => DateTime(now.year - 1, now.month),
      _Range.year2 => DateTime(now.year - 2, now.month),
      _Range.all => DateTime(i.createdAt.year, i.createdAt.month),
    };
    final end = fixed ? (maturityDateOf(i) ?? now) : now;
    final months = <DateTime>[];
    for (var d = DateTime(start.year, start.month); !d.isAfter(end); d = DateTime(d.year, d.month + 1)) {
      months.add(DateTime(d.year, d.month + 1, 0));
    }
    if (months.length < 2) months.insert(0, DateTime(start.year, start.month, 1));
    double valueAt(DateTime d) {
      if (fixed) return currentValue(i, now: d);
      final snaps = i.snapshots.where((s) => !s.date!.isAfter(d)).toList();
      return snaps.isEmpty ? 0 : snaps.last.value;
    }

    double investedAt(DateTime d) =>
        (i.openingDate != null && !i.openingDate!.isAfter(d) ? i.openingInvested : 0) +
        txns.where((t) => t.type == 'expense' && !t.createdAt.isAfter(d)).fold(0.0, (s, t) => s + t.amount) -
        i.withdrawals.where((w) => !w.date!.isAfter(d)).fold(0.0, (s, w) => s + w.investedReduction);

    final chart = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!fixed)
        Wrap(spacing: 8, children: [
          for (final r in _Range.values)
            ChoiceChip(
              label: Text(switch (r) {
                _Range.year1 => '1 ${l.msLoansYear.toLowerCase()}',
                _Range.year2 => '2 ${l.msLoansYears.toLowerCase()}',
                _Range.all => l.msRecRangeAll,
              }),
              selected: _range == r,
              onSelected: (_) => setState(() => _range = r),
            ),
        ]),
      const SizedBox(height: 12),
      ToolLineChart(
        height: 132,
        xLabels: [for (final d in months) DateFormat('MMM', AppLocale.current.languageCode).format(d)],
        series: [
          ChartSeries(
              name: l.msInvLegendValue, points: [for (final d in months) valueAt(d)], color: cs.primary, fill: true),
          if (!fixed)
            ChartSeries(
                name: l.msInvLegendInvested,
                points: [for (final d in months) investedAt(d)],
                color: cs.onSurfaceVariant,
                dashed: true),
        ],
      ),
    ]);

    // Activity log, newest first.
    final entries = <(DateTime, Widget)>[];
    for (final (idx, s) in i.snapshots.indexed) {
      entries.add((
        s.date!,
        KuberListRow(
          leading: const KuberIconTile(icon: Icons.edit_note_rounded, tone: KuberTone.secondary),
          title: l.msInvActValue,
          subtitle: fmtDayLong(s.date!),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(m(s.value), style: tt.titleSmall),
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              itemBuilder: (_) => [
                PopupMenuItem(value: 0, child: Text(l.editLabel)),
                PopupMenuItem(value: 1, child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
              ],
              onSelected: (v) async {
                final service = InvestmentService(ref.read(isarProvider));
                if (v == 1) {
                  await service.deleteSnapshot(i, idx);
                } else if (context.mounted) {
                  await showValueSheet(context, ref, i, editIndex: idx);
                }
                ref.invalidate(investmentListProvider);
              },
            ),
          ]),
        ),
      ));
    }
    for (final t in txns) {
      final isSip = t.occurrenceDate != null || t.name.startsWith('Contribution - ');
      final isOut = t.type == 'income';
      entries.add((
        t.createdAt,
        KuberListRow(
          leading: KuberIconTile(
              icon: isOut ? Icons.output_rounded : Icons.add_rounded,
              tone: isOut ? KuberTone.expense : KuberTone.income),
          title: isOut ? l.msInvActWithdrawal : (isSip ? l.msInvActSip : l.msInvActTopUp),
          subtitle: '${fmtDayLong(t.createdAt)} · ${l.msInvTransaction}',
          trailing: Text('${isOut ? '-' : '+'}${m(t.amount)}', style: tt.titleSmall),
          onTap: () => showTransactionDetailSheet(context, ref, t),
        ),
      ));
    }
    if (i.openingInvested > 0 && i.openingDate != null) {
      entries.add((
        i.openingDate!,
        KuberListRow(
          leading: const KuberIconTile(icon: Icons.flag_outlined, tone: KuberTone.neutral),
          title: l.msInvActOpening,
          subtitle: fmtDayLong(i.openingDate!),
          trailing: Text(m(i.openingInvested), style: tt.titleSmall),
        ),
      ));
    }
    if (fixed) {
      entries.add((
        i.fixedStart!,
        KuberListRow(
          leading: const KuberIconTile(icon: Icons.savings_outlined, tone: KuberTone.income),
          title: l.msInvActOpened,
          subtitle: fmtDayLong(i.fixedStart!),
          trailing: Text(m(i.fixedPrincipal ?? i.installment ?? 0), style: tt.titleSmall),
        ),
      ));
      for (var y = 1; ; y++) {
        final d = DateTime(i.fixedStart!.year + y, i.fixedStart!.month, i.fixedStart!.day);
        if (d.isAfter(now)) break;
        final prev = currentValue(i, now: DateTime(d.year - 1, d.month, d.day));
        entries.add((
          d,
          KuberListRow(
            leading: const KuberIconTile(icon: Icons.trending_up_rounded, tone: KuberTone.secondary),
            title: l.msInvActInterest,
            subtitle: fmtDayLong(d),
            trailing: Text('+${m(currentValue(i, now: d) - prev)}', style: tt.titleSmall),
          ),
        ));
      }
    }
    entries.sort((a, b) => b.$1.compareTo(a.$1));

    return MoneyFullScreen(
      title: i.name,
      overflow: [
        PopupMenuItem(value: () => context.push('/investments/edit', extra: i), child: Text(l.editLabel)),
        if (i.status == InvestmentStatus.active && !fixed)
          PopupMenuItem(
              value: () => showWithdrawSheet(context, ref, i, everything: true), child: Text(l.msInvWithdrawAll)),
        PopupMenuItem(
            value: () => confirmDeleteInvestment(context, ref, i).then((ok) {
                  if (ok && context.mounted) Navigator.of(context).pop();
                }),
            child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
      ],
      identity: MoneyIdentity(
        tile: HoldingIcon(i, size: 48),
        contextLabel: investmentTypeLabel(context, i.investmentType),
        headline: m(value),
        caption: fixed
            ? l.msInvMatures(fmtDayLong(maturityDateOf(i) ?? now))
            : '${gain >= 0 ? '+' : '-'}${m(gain.abs())} · ${xirr == null ? '' : '${l.msInvXirr} ${fmt.formatPercentage(xirr * 100)}'}',
      ),
      chart: chart,
      list: [
        KuberSectionHeader(title: l.msInvActivity),
        if (fixed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.msInvInterestLocked, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ),
        KuberGroup(children: [for (final e in entries) e.$2]),
        if (!fixed) ...[
          const SizedBox(height: 12),
          AppButton(
            label: l.msInvAddPast,
            type: AppButtonType.outline,
            fullWidth: true,
            onPressed: () => showValueSheet(context, ref, i, past: true),
          ),
        ],
        if (gain != 0 && !fixed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${l.msInvLegendGain}: ${gain >= 0 ? '+' : '-'}${m(gain.abs())}',
              style: tt.bodySmall!.copyWith(color: gain >= 0 ? money.income : money.expense),
            ),
          ),
      ],
    );
  }
}

// ── Update value / past value ───────────────────────────────────────────

Future<void> showValueSheet(BuildContext context, WidgetRef ref, Investment i,
        {bool past = false, int? editIndex}) =>
    showMoneySheet<void>(context, _ValueSheet(investment: i, past: past, editIndex: editIndex));

class _ValueSheet extends ConsumerStatefulWidget {
  final Investment investment;
  final bool past;
  final int? editIndex;
  const _ValueSheet({required this.investment, required this.past, this.editIndex});

  @override
  ConsumerState<_ValueSheet> createState() => _ValueSheetState();
}

class _ValueSheetState extends ConsumerState<_ValueSheet> {
  final _value = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final idx = widget.editIndex;
    if (idx != null) {
      final s = widget.investment.snapshots[idx];
      _date = s.date!;
      _value.text = s.value.round().toString();
    } else {
      _date = DateUtils.dateOnly(DateTime.now());
    }
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final i = widget.investment;
    final v = KuberAmountField.valueOf(_value);
    return KuberBottomSheet(
      title: widget.past ? l.msInvAddPastTitle : l.msInvUpdateValue,
      description: i.name,
      actions: AppButton(
        label: l.saveLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: v <= 0
            ? null
            : () async {
                final service = InvestmentService(ref.read(isarProvider));
                if (widget.editIndex != null) {
                  await service.editSnapshot(i, widget.editIndex!, date: _date, value: v);
                } else {
                  await service.updateValue(i, v, date: widget.past ? _date : null);
                }
                ref.invalidate(investmentListProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showKuberSnackBar(context, l.msInvValuesUpdated);
                }
              },
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        KuberAmountField(
          label: widget.past ? l.msInvValueOnDate : l.msInvNewValue,
          controller: _value,
          symbol: fmt.symbol,
          indianGrouping: fmt.system == NumberSystem.indian,
          onChanged: (_) => setState(() {}),
        ),
        if (widget.past || widget.editIndex != null) ...[
          const SizedBox(height: 12),
          DatePickerRow(
            label: l.msInvDate,
            value: fmtDayLong(_date),
            initial: _date,
            last: DateTime.now(),
            onChanged: (d) => setState(() => _date = d),
          ),
          const SizedBox(height: 12),
          Text(l.msInvPastHelp, style: Theme.of(context).textTheme.bodySmall),
        ],
      ]),
    );
  }
}

// ── Add money ──────────────────────────────────────────────────────────

void showAddMoneySheet(BuildContext context, WidgetRef ref, Investment i) =>
    showMoneySheet<void>(context, _AddMoneySheet(investment: i));

class _AddMoneySheet extends ConsumerStatefulWidget {
  final Investment investment;
  const _AddMoneySheet({required this.investment});

  @override
  ConsumerState<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends ConsumerState<_AddMoneySheet> {
  final _amount = TextEditingController();
  late int? _accountId = int.tryParse(widget.investment.accountId ?? '');
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final v = KuberAmountField.valueOf(_amount);
    return KuberBottomSheet(
      title: l.msInvAddMoney,
      description: widget.investment.name,
      actions: AppButton(
        label: l.saveLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: v <= 0 || _accountId == null
            ? null
            : () async {
                await InvestmentService(ref.read(isarProvider))
                    .addMoney(widget.investment, amount: v, accountId: '$_accountId', date: _date);
                ref.invalidate(investmentListProvider);
                ref.invalidate(transactionListProvider);
                if (context.mounted) Navigator.of(context).pop();
              },
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        KuberAmountField(
          label: l.msRecAmount,
          controller: _amount,
          symbol: fmt.symbol,
          indianGrouping: fmt.system == NumberSystem.indian,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AccountPickerRow(
            label: l.msInvFromAccount, selectedId: _accountId, onChanged: (id) => setState(() => _accountId = id)),
        const SizedBox(height: 10),
        DatePickerRow(
            label: l.msInvDate, value: fmtDayLong(_date), initial: _date, onChanged: (d) => setState(() => _date = d)),
      ]),
    );
  }
}

// ── Withdraw / close / FD early (I.5) ──────────────────────────────────

void showWithdrawSheet(BuildContext context, WidgetRef ref, Investment i, {bool everything = false}) =>
    showMoneySheet<void>(context, _WithdrawSheet(investment: i, everything: everything));

class _WithdrawSheet extends ConsumerStatefulWidget {
  final Investment investment;
  final bool everything;
  const _WithdrawSheet({required this.investment, required this.everything});

  @override
  ConsumerState<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends ConsumerState<_WithdrawSheet> {
  final _redeemed = TextEditingController();
  final _exitLoad = TextEditingController();
  final _tax = TextEditingController();
  final _received = TextEditingController();
  final _penalty = TextEditingController(text: '1');
  bool _receivedEdited = false;
  bool _closing = false;
  late int? _accountId = int.tryParse(widget.investment.accountId ?? '');
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  Investment get i => widget.investment;
  bool get _fd => hasFixedTerms(i);

  @override
  void initState() {
    super.initState();
    if (widget.everything || _fd) _redeemed.text = currentValue(i).round().toString();
    _syncReceived();
  }

  @override
  void dispose() {
    for (final c in [_redeemed, _exitLoad, _tax, _received, _penalty]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => KuberAmountField.valueOf(c);

  ({double rateAfterPenalty, double received, double interestEarned})? get _fdEarly => _fd
      ? fdPrematureWithdrawal(
          principal: i.fixedPrincipal ?? 0,
          rate: i.fixedRate ?? 0,
          penaltyRate: double.tryParse(_penalty.text) ?? 0,
          freq: i.compounding,
          start: i.fixedStart!,
          at: _date)
      : null;

  void _syncReceived() {
    if (_receivedEdited) return;
    final r = _fd ? (_fdEarly?.received ?? 0) : _v(_redeemed) - _v(_exitLoad) - _v(_tax);
    _received.text = r > 0 ? r.round().toString() : '';
  }

  Future<void> _submit({required bool close}) async {
    final l = context.l10n;
    await InvestmentService(ref.read(isarProvider)).withdraw(i,
        redeemed: _v(_redeemed),
        charges: _v(_exitLoad) + _v(_tax),
        received: _v(_received),
        accountId: '$_accountId',
        date: _date,
        closeAfter: close);
    ref.invalidate(investmentListProvider);
    ref.invalidate(transactionListProvider);
    if (mounted) {
      Navigator.of(context).pop();
      if (close) showKuberSnackBar(context, l.msInvClosedSnack(i.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final indian = fmt.system == NumberSystem.indian;
    String m(num v) => fmt.formatCurrency(v.round());
    final value = currentValue(i);
    final invested = investedOf(i);
    final redeemed = _v(_redeemed);
    final all = redeemed >= value - 0.5 || _fd;
    final w = proportionalWithdrawal(
        invested: invested, value: value, redeemed: redeemed, charges: _v(_exitLoad) + _v(_tax), received: _v(_received));
    final ready = redeemed > 0 && _accountId != null && _v(_received) > 0;

    if (_closing) {
      final txns = ref.watch(investmentTransactionsProvider(i.uid)).valueOrNull ?? const [];
      final x = xirr([
        ...cashFlows(i, txns).where((f) => f.amount < 0),
        CashFlow(_date, _v(_received)),
      ]);
      final held = (_date.difference(i.createdAt).inDays / 30.4).round();
      return KuberBottomSheet(
        title: l.msInvCloseTitle(i.name),
        actions: Row(children: [
          Expanded(
              child: AppButton(
                  label: l.msInvBack, type: AppButtonType.outline, onPressed: () => setState(() => _closing = false))),
          const SizedBox(width: 12),
          Expanded(
              child: AppButton(
                  label: l.msInvCloseCta, type: AppButtonType.primary, onPressed: () => _submit(close: true))),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.msInvCloseBody(m(_v(_received))), style: tt.bodyMedium),
          const SizedBox(height: 16),
          KvGrid(columns: 2, items: [
            KvItem(l.msInvCloseInvested, m(invested)),
            KvItem(l.msInvCloseReceived, m(_v(_received))),
            KvItem(l.msInvCloseReturn, fmt.formatPercentage(percentGain(_v(_received), invested))),
            KvItem(l.msInvCloseXirr, x == null ? '-' : fmt.formatPercentage(x * 100)),
            KvItem(l.msInvCloseHeld, l.msInvHeldValue('$held')),
          ]),
          const SizedBox(height: 12),
          Text(l.msInvCloseHelp, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ]),
      );
    }

    final early = _fdEarly;
    return KuberBottomSheet(
      title: _fd ? l.msInvWithdrawEarly : l.msInvWithdraw,
      description: i.name,
      actions: AppButton(
        label: _fd ? l.msInvWithdrawClose : l.msInvWithdraw,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: !ready ? null : () => all ? setState(() => _closing = true) : _submit(close: false),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(l.msInvValueLine(m(value)), style: tt.titleSmall)),
          if (!_fd)
            TextButton(
              onPressed: () => setState(() {
                _redeemed.text = value.round().toString();
                _syncReceived();
              }),
              child: Text(l.msInvWithdrawAll),
            ),
        ]),
        const SizedBox(height: 8),
        if (_fd) ...[
          KuberTextField.number(
            label: l.msInvPenalty,
            controller: _penalty,
            suffixText: '%',
            helperText: l.msInvPenaltySupport,
            onChanged: (_) => setState(_syncReceived),
          ),
          if (early != null) ...[
            const SizedBox(height: 12),
            KuberGroup(children: [
              KuberListRow(dense: true, title: fmt.formatPercentage(early.rateAfterPenalty), subtitle: l.msInvRateAfterPenalty),
              KuberListRow(dense: true, title: m(early.interestEarned), subtitle: l.msInvInterestEarned),
              KuberListRow(dense: true, title: m(value - early.received), subtitle: l.msInvLessThanToday),
            ]),
          ],
        ] else ...[
          KuberAmountField(
            label: l.msInvRedeemed,
            controller: _redeemed,
            symbol: fmt.symbol,
            indianGrouping: indian,
            onChanged: (_) => setState(_syncReceived),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: KuberAmountField(
                    label: l.msInvExitLoad,
                    controller: _exitLoad,
                    symbol: fmt.symbol,
                    indianGrouping: indian,
                    onChanged: (_) => setState(_syncReceived))),
            const SizedBox(width: 12),
            Expanded(
                child: KuberAmountField(
                    label: l.msInvTax,
                    controller: _tax,
                    symbol: fmt.symbol,
                    indianGrouping: indian,
                    onChanged: (_) => setState(_syncReceived))),
          ]),
        ],
        const SizedBox(height: 12),
        KuberAmountField(
          label: l.msInvReceived,
          controller: _received,
          symbol: fmt.symbol,
          indianGrouping: indian,
          calculatedLabel: _receivedEdited ? null : l.msCalculated,
          onChanged: (_) => setState(() => _receivedEdited = true),
        ),
        if (!_fd && redeemed > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: KuberShape.largeR),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: Text(l.msInvAfter, style: tt.titleSmall)),
                KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.proportional)),
              ]),
              const SizedBox(height: 8),
              Text('${l.msInvInvested}: ${m(invested)} → ${m(invested - w.investedReduction)}', style: tt.bodyMedium),
              Text('${l.msInvRealized}: ${w.realizedGain >= 0 ? '+' : '-'}${m(w.realizedGain.abs())}',
                  style: tt.bodyMedium),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        AccountPickerRow(
            label: l.msInvToAccount, selectedId: _accountId, onChanged: (id) => setState(() => _accountId = id)),
        const SizedBox(height: 10),
        DatePickerRow(
            label: l.msInvDate,
            value: fmtDayLong(_date),
            initial: _date,
            last: DateTime.now(),
            onChanged: (d) => setState(() {
                  _date = d;
                  _syncReceived();
                })),
      ]),
    );
  }
}
