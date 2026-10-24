// Loans (design L.1): hero with total outstanding, monthly EMIs and the next
// EMI; Active rows with progress; Closed collapsed; Add loan.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../settings/providers/info_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../domain/loan_engine.dart';
import '../providers/loan_provider.dart';
import '../widgets/loan_sheet.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  bool _closedOpen = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoLoans), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.loans);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoLoans).notifier).markSeen();
        });
      }
    });
    final loans = ref.watch(loanListProvider).valueOrNull;
    final txns = ref.watch(transactionListProvider).valueOrNull ?? const <Transaction>[];
    final byLoan = <String, List<Transaction>>{};
    for (final t in txns) {
      if (t.linkedRuleType == 'loan' && t.linkedRuleId != null) {
        byLoan.putIfAbsent(t.linkedRuleId!, () => []).add(t);
      }
    }
    final items = [
      for (final loan in loans ?? const <Loan>[])
        (loan, loanStatus(loan, byLoan[loan.uid] ?? const [])),
    ];
    final active = items.where((e) => !e.$2.closed).toList()
      ..sort((a, b) => (a.$2.nextDay ?? 99999999).compareTo(b.$2.nextDay ?? 99999999));
    final closed = items.where((e) => e.$2.closed).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: l.msLoansFab,
        onPressed: () => context.push('/loans/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: KuberAppBar(showBack: true, title: l.loansTitle, infoConfig: InfoConstants.loans),
        ),
        if (loans == null)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
              icon: Icons.account_balance_rounded,
              title: l.msLoansEmptyTitle,
              description: l.msLoansEmptyBody,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin, 0, KuberSpace.screenMargin, KuberExtendedFab.clearance),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _Hero(active: active),
                if (active.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: KuberSpace.sectionGap),
                    child: KuberSectionHeader(
                      title: l.msLoansActive,
                      trailing: Text('${active.length}',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ),
                  KuberGroup(children: [for (final e in active) _LoanRow(loan: e.$1, st: e.$2)]),
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
                        Text('${closed.length}',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(width: 8),
                        Icon(_closedOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: cs.onSurfaceVariant),
                      ]),
                    ),
                  ),
                  if (_closedOpen) ...[
                    const SizedBox(height: 8),
                    KuberGroup(children: [for (final e in closed) _LoanRow(loan: e.$1, st: e.$2)]),
                  ],
                ],
              ]),
            ),
          ),
      ]),
    );
  }
}

class _Hero extends ConsumerWidget {
  final List<(Loan, LoanStatus)> active;
  const _Hero({required this.active});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final outstanding = active.fold(0.0, (s, e) => s + (e.$2.outstanding ?? 0));
    final monthly = active.fold(0.0, (s, e) => s + (e.$2.nextAmount ?? e.$1.emiAmount));
    final next = active.where((e) => e.$2.nextDay != null).firstOrNull;
    // First KPI left, second right, a gap between; big values shrink to
    // fit instead of touching.
    Widget col(String label, String value, {bool end = false}) => Expanded(
          child: Column(
              crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    textAlign: end ? TextAlign.end : TextAlign.start,
                    style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: end ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(value,
                      style: tt.headlineMedium!
                          .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ),
              ]),
        );
    return KuberCard(
      hero: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          col(l.msLoansTotalOutstanding, fmt.formatCurrency(outstanding.round())),
          const SizedBox(width: KuberSpace.lg),
          col(l.msLoansMonthlyEmis, fmt.formatCurrency(monthly.round()), end: true),
        ]),
        if (next != null) ...[
          const SizedBox(height: 12),
          Text(
            l.msLoansNextEmiLine(fmtDayShort(dayOf(next.$2.nextDay!)), next.$1.name,
                fmt.formatCurrency((next.$2.nextAmount ?? next.$1.emiAmount).round())),
            style: tt.bodySmall!.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ]),
    );
  }
}

class _LoanRow extends ConsumerWidget {
  final Loan loan;
  final LoanStatus st;
  const _LoanRow({required this.loan, required this.st});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final today = todayKey();
    final due = st.nextDay != null && st.nextDay! <= today;
    final sub = st.closed
        ? fmt.formatCurrency(loan.emiAmount.round())
        : st.nextDay == null
            ? '${fmt.formatCurrency(loan.emiAmount.round())} ${l.msLoansEmi}'
            // Due rows are amber and say so ("due today") rather than a date.
            : due
                ? '${fmt.formatCurrency((st.nextAmount ?? loan.emiAmount).round())} ${l.msLoansEmi} · ${l.msWhenFlagToday}'
                : l.msLoansRowSub(fmt.formatCurrency((st.nextAmount ?? loan.emiAmount).round()),
                    fmtDayShort(dayOf(st.nextDay!)));
    return InkWell(
      onTap: () => showLoanSheet(context, ref, loan),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            KuberIconTile(
                icon: loanTypeIcon(loan.loanType),
                tone: st.closed ? KuberTone.neutral : KuberTone.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(loan.name,
                    style: tt.titleMedium!.copyWith(color: st.closed ? cs.onSurfaceVariant : null)),
                Text(sub,
                    style: tt.bodyMedium!.copyWith(
                        color: due && !st.closed ? context.kuberMoney.warning : cs.onSurfaceVariant)),
                if (st.closed) ...[const SizedBox(height: 4), StatePill(l.msClosed)],
              ]),
            ),
            if (st.outstanding != null && !st.closed)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(fmt.formatCurrency(st.outstanding!.round()), style: tt.titleMedium),
                Text(l.msLoansLeft, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ]),
          ]),
          if (st.totalEmis != null && !st.closed) ...[
            const SizedBox(height: 12),
            KuberLinearProgress(value: st.progress),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Text(l.msLoansProgress('${st.emisPaid}', '${st.totalEmis}'),
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ),
              Text(loan.lenderName, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ]),
          ],
        ]),
      ),
    );
  }
}
