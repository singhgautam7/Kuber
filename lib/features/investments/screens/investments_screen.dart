// Investments (design I.1): portfolio hero (value, invested, gain, XIRR,
// allocation, Update values), FD maturity card, holdings by asset class,
// Closed collapsed, Add investment.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/money_math/investment_math.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/info_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/investment.dart';
import '../domain/investment_engine.dart';
import '../domain/investment_service.dart';
import '../providers/investment_provider.dart';
import '../widgets/holding_sheet.dart';

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  bool _closedOpen = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoInvestments), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.investments);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoInvestments).notifier).markSeen();
        });
      }
    });
    final invs = ref.watch(investmentListProvider).valueOrNull;
    final txns = ref.watch(transactionListProvider).valueOrNull ?? const <Transaction>[];
    final byInv = <String, List<Transaction>>{};
    for (final t in txns) {
      if (t.linkedRuleType == 'investment' && t.linkedRuleId != null) {
        byInv.putIfAbsent(t.linkedRuleId!, () => []).add(t);
      }
    }
    final active = (invs ?? const <Investment>[]).where((i) => i.status == InvestmentStatus.active).toList();
    final closed = (invs ?? const <Investment>[]).where((i) => i.status == InvestmentStatus.closed).toList();
    final matured = active
        .where((i) =>
            hasFixedTerms(i) &&
            !i.maturityHandled &&
            maturityDateOf(i) != null &&
            !maturityDateOf(i)!.isAfter(DateTime.now()))
        .toList();
    final groups = <InvestmentGroup, List<Investment>>{};
    for (final i in active) {
      groups.putIfAbsent(groupOf(i), () => []).add(i);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: l.msInvFab,
        onPressed: () => context.push('/investments/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: KuberAppBar(showBack: true, title: l.investmentsTitle, infoConfig: InfoConstants.investments),
        ),
        if (invs == null)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (invs.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
                icon: Icons.trending_up_rounded, title: l.msInvEmptyTitle, description: l.msInvEmptyBody),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin, 0, KuberSpace.screenMargin, KuberExtendedFab.clearance),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                for (final i in matured) ...[_MaturedCard(investment: i), const SizedBox(height: 12)],
                _PortfolioHero(active: active, txns: byInv),
                for (final g in InvestmentGroup.values)
                  if (groups[g] != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: KuberSpace.sectionGap),
                      child: KuberSectionHeader(
                        title: _groupLabel(context, g),
                        trailing: Text(
                          ref.watch(formatterProvider).formatCurrency(
                              groups[g]!.fold(0.0, (s, i) => s + currentValue(i)).round()),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    KuberGroup(children: [for (final i in groups[g]!) _HoldingRow(investment: i)]),
                  ],
                if (closed.isNotEmpty) ...[
                  const SizedBox(height: KuberSpace.sectionGap),
                  KuberCard(
                    onTap: () => setState(() => _closedOpen = !_closedOpen),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 56,
                      child: Row(children: [
                        Expanded(child: Text(l.msClosed, style: Theme.of(context).textTheme.titleSmall)),
                        Text('${closed.length}'),
                        const SizedBox(width: 8),
                        Icon(_closedOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                      ]),
                    ),
                  ),
                  if (_closedOpen) ...[
                    const SizedBox(height: 8),
                    KuberGroup(children: [for (final i in closed) _HoldingRow(investment: i)]),
                  ],
                ],
              ]),
            ),
          ),
      ]),
    );
  }
}

String _groupLabel(BuildContext context, InvestmentGroup g) {
  final l = context.l10n;
  return switch (g) {
    InvestmentGroup.mutualFunds => l.msInvGroupMutualFunds,
    InvestmentGroup.stocks => l.msInvGroupStocks,
    InvestmentGroup.gold => l.msInvGroupGold,
    InvestmentGroup.crypto => l.msInvGroupCrypto,
    InvestmentGroup.fixed => l.msInvGroupFixed,
    InvestmentGroup.other => l.msInvGroupOther,
  };
}

class _PortfolioHero extends ConsumerWidget {
  final List<Investment> active;
  final Map<String, List<Transaction>> txns;
  const _PortfolioHero({required this.active, required this.txns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    String m(num v) => fmt.formatCurrency(v.round());
    final value = active.fold(0.0, (s, i) => s + currentValue(i));
    final invested = active.fold(0.0, (s, i) => s + investedOf(i));
    final gain = value - invested;
    final x = xirr([for (final i in active) ...cashFlows(i, txns[i.uid] ?? const [])]);
    final byGroup = <InvestmentGroup, double>{};
    for (final i in active) {
      byGroup[groupOf(i)] = (byGroup[groupOf(i)] ?? 0) + currentValue(i);
    }
    final palette = [cs.primary, cs.tertiary, money.warning, money.income, cs.secondary, cs.outline];
    final groups = byGroup.entries.where((e) => e.value > 0).toList();
    return KuberCard(
      hero: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.msInvPortfolio.toUpperCase(),
            style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
        Text(m(value), style: tt.headlineMedium),
        const SizedBox(height: 12),
        KvGrid(items: [
          KvItem(l.msInvInvested, m(invested)),
          KvItem(l.msInvGain, '${gain >= 0 ? '+' : '-'}${m(gain.abs())}',
              valueColor: gain >= 0 ? money.income : money.expense),
          KvItem(l.msInvXirr, x == null ? '-' : fmt.formatPercentage(x * 100),
              onInfo: () => showMoneyInfo(context, ref, MoneyInfo.xirr)),
        ]),
        const SizedBox(height: 4),
        Text(l.msInvOverall(fmt.formatPercentage(percentGain(value, invested))),
            style: tt.bodySmall!.copyWith(color: gain >= 0 ? money.income : money.expense)),
        if (groups.isNotEmpty) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: KuberShape.fullR,
            child: SizedBox(
              height: 12,
              child: Row(children: [
                for (final (idx, e) in groups.indexed) ...[
                  if (idx > 0) const SizedBox(width: 2),
                  Expanded(
                      flex: (e.value / value * 1000).round().clamp(1, 1000),
                      child: Container(color: palette[e.key.index % palette.length])),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(runSpacing: 6, children: [
            for (final e in groups)
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 2,
                child: Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: palette[e.key.index % palette.length], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_groupLabel(context, e.key), style: tt.bodySmall)),
                  Text(fmt.formatPercentage(e.value / value * 100), style: tt.bodySmall),
                ]),
              ),
          ]),
        ],
        const SizedBox(height: 12),
        AppButton(
          label: l.msInvUpdateValues,
          icon: Icons.edit_note_rounded,
          type: AppButtonType.normal,
          fullWidth: true,
          onPressed: () => context.push('/investments/update-values'),
        ),
      ]),
    );
  }
}

class _HoldingRow extends ConsumerWidget {
  final Investment investment;
  const _HoldingRow({required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final i = investment;
    String m(num v) => fmt.formatCurrency(v.round());
    final value = currentValue(i);
    final invested = investedOf(i);
    final closed = i.status == InvestmentStatus.closed;
    final gain = closed ? realizedGainOf(i) : value - invested;
    final stale = staleDays(i);
    final last = lastValueDate(i);
    final sub = hasFixedTerms(i)
        ? l.msInvMatures(fmtDayShort(maturityDateOf(i)!))
        : i.behaviour == InvestmentBehaviour.other && last != null
            ? l.msInvUpdatedOn(fmtMonthYear(last))
            : investmentTypeLabel(context, i.investmentType);
    return InkWell(
      onTap: () => showHoldingSheet(context, ref, i),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text(i.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium!.copyWith(color: closed ? cs.onSurfaceVariant : null)),
              ),
              Text(m(closed ? withdrawnOf(i) : value), style: tt.titleMedium),
            ]),
            Row(children: [
              Expanded(child: Text(sub, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
              Text(
                '${gain >= 0 ? '+' : '-'}${m(gain.abs())} · ${fmt.formatPercentage(invested == 0 ? 0 : gain / invested * 100)}',
                style: tt.bodySmall!.copyWith(color: gain >= 0 ? money.income : money.expense),
              ),
            ]),
            if (closed) ...[const SizedBox(height: 4), Align(alignment: Alignment.centerLeft, child: StatePill(l.msClosed))],
            if (stale != null && !closed)
              Row(children: [
                Icon(Icons.schedule_rounded, size: 16, color: money.warning),
                const SizedBox(width: 4),
                Text(l.msInvStale('$stale'), style: tt.bodyMedium!.copyWith(color: money.warning)),
              ]),
          ]),
        ),
      ),
    );
  }
}

class _MaturedCard extends ConsumerWidget {
  final Investment investment;
  const _MaturedCard({required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final i = investment;
    final account = ref.watch(accountMapProvider).valueOrNull?[int.tryParse(i.accountId ?? '')];
    final amount = fmt.formatCurrency((maturityValue(i) ?? currentValue(i)).round());
    final accountName = account?.name ?? '';
    final service = InvestmentService(ref.read(isarProvider));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: KuberShape.cardR),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.celebration_rounded, size: 24, color: cs.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.msInvMatured(amount, accountName),
                  style: tt.titleMedium!.copyWith(color: cs.onPrimaryContainer)),
              Text(l.msInvMaturedSub(i.name, fmtDayShort(maturityDateOf(i)!)),
                  style: tt.bodySmall!.copyWith(color: cs.onPrimaryContainer)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: AppButton(
              label: l.msInvRenew,
              type: AppButtonType.outline,
              onPressed: () async {
                await service.renew(i);
                ref.invalidate(investmentListProvider);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: l.msInvMove(accountName),
              type: AppButtonType.primary,
              onPressed: i.accountId == null
                  ? null
                  : () async {
                      await service.moveMatured(i, i.accountId!);
                      ref.invalidate(investmentListProvider);
                      ref.invalidate(transactionListProvider);
                    },
            ),
          ),
        ]),
      ]),
    );
  }
}

/// Update values (design I.4): every market-valued and other holding,
/// stalest first, one Save for all entered values.
class UpdateValuesScreen extends ConsumerStatefulWidget {
  const UpdateValuesScreen({super.key});

  @override
  ConsumerState<UpdateValuesScreen> createState() => _UpdateValuesScreenState();
}

class _UpdateValuesScreenState extends ConsumerState<UpdateValuesScreen> {
  final _ctrls = <int, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final list = (ref.watch(investmentListProvider).valueOrNull ?? const <Investment>[])
        .where((i) => i.status == InvestmentStatus.active && !hasFixedTerms(i))
        .toList()
      ..sort((a, b) => (lastValueDate(a) ?? a.updatedAt).compareTo(lastValueDate(b) ?? b.updatedAt));
    final entered = {
      for (final i in list)
        if (KuberAmountField.valueOf(_ctrls[i.id] ?? TextEditingController()) > 0)
          i: KuberAmountField.valueOf(_ctrls[i.id]!)
    };
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        title: l.msInvUpdateValues,
        subtitle: l.msInvUpdSub('${list.length}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        children: [
          Text(l.msInvUpdHelp, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          KuberGroup(children: [
            for (final i in list)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  HoldingIcon(i),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(i.name, style: tt.titleSmall),
                      Text(
                        '${fmt.formatCurrency(currentValue(i).round())} · ${fmtDayShort(lastValueDate(i) ?? i.updatedAt)}',
                        style: tt.bodySmall!.copyWith(
                            color: staleDays(i) != null ? money.warning : cs.onSurfaceVariant),
                      ),
                    ]),
                  ),
                  SizedBox(
                    width: 112,
                    child: KuberAmountField(
                      label: l.msInvNewValue,
                      showLabel: false,
                      hint: l.msInvNewValue,
                      controller: _ctrls.putIfAbsent(i.id, TextEditingController.new),
                      symbol: fmt.symbol,
                      indianGrouping: fmt.system == NumberSystem.indian,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ]),
              ),
          ]),
        ],
      ),
      bottomNavigationBar: KuberSaveButton(
        label: entered.isEmpty ? l.msInvSaveEmpty : l.msInvSaveN('${entered.length}'),
        onPressed: entered.isEmpty
            ? null
            : () async {
                await InvestmentService(ref.read(isarProvider)).updateValues(entered);
                ref.invalidate(investmentListProvider);
                final all = ref.read(investmentListProvider).valueOrNull ?? const [];
                final total = all
                    .where((i) => i.status == InvestmentStatus.active)
                    .fold(0.0, (s, i) => s + currentValue(i));
                if (context.mounted) {
                  showKuberSnackBar(context, l.msInvSaved('${entered.length}', fmt.formatCurrency(total.round())));
                  context.pop();
                }
              },
      ),
    );
  }
}
