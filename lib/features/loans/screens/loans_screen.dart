import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../settings/providers/info_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../providers/loan_provider.dart';
import '../utils/loan_calculations.dart' as calc;
import '../widgets/loan_detail_sheet.dart';
import '../widgets/loan_widgets.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  bool _showCompleted = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoLoans), (
      prev,
      next,
    ) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.loans);
          ref
              .read(infoSeenProvider(PrefsKeys.seenInfoLoans).notifier)
              .markSeen();
        });
      }
    });

    final cs = Theme.of(context).colorScheme;
    final loansAsync = ref.watch(loanListProvider);
    final txnsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: context.l10n.addLoan,
        onPressed: () => context.push('/loans/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: localeFont(color: cs.onSurfaceVariant),
          ),
        ),
        data: (loans) {
          final allTxns = txnsAsync.valueOrNull ?? [];
          // Header search: name, lender, type or reference. While searching
          // the hero hides and matching completed loans show expanded.
          final q = _query.trim().toLowerCase();
          final shown = q.isEmpty
              ? loans
              : [
                  for (final l in loans)
                    if ([
                      l.name,
                      l.lenderName,
                      l.loanType,
                      l.referenceNumber ?? '',
                    ].any((f) => f.toLowerCase().contains(q)))
                      l,
                ];
          final showCompleted = _showCompleted || q.isNotEmpty;
          final active = shown.where((l) => !l.isCompleted).toList();
          final completed = shown.where((l) => l.isCompleted).toList();
          final totalPrincipal = loans.fold<double>(
            0,
            (sum, l) => sum + l.principalAmount,
          );
          final totalPaid = calc.totalPaidAllLoans(loans, allTxns);
          final totalOutstanding = calc.totalOutstanding(loans, allTxns);
          final nextDue = loans
              .where((l) => !l.isCompleted)
              .map(calc.computeNextDueDate)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (a, b) => a == null || b.isBefore(a) ? b : a,
              );

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: context.l10n.loansTitle,
                  infoConfig: InfoConstants.loans,
                  search: loans.isEmpty
                      ? null
                      : KuberHeaderSearch(
                          controller: _searchController,
                          hint: context.l10n.searchLoansHint,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                ),
              ),

              if (shown.isEmpty && q.isNotEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.l10n.noMatches,
                    description: context.l10n.nothingMatchesQuery(
                      _query.trim(),
                    ),
                  ),
                ),
              if (loans.isNotEmpty && q.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin,
                    0,
                    KuberSpace.screenMargin,
                    KuberSpace.sectionGap,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LoansHero(
                      totalPrincipal: totalPrincipal,
                      totalPaid: totalPaid,
                      totalOutstanding: totalOutstanding,
                      activeCount: loans.where((l) => !l.isCompleted).length,
                      nextDue: nextDue,
                    ),
                  ),
                ),
              if (loans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.account_balance_outlined,
                    title: context.l10n.noLoansAdded,
                    description: context.l10n.loansEmptyDesc,
                  ),
                ),
              // Board 3.21: active loans as one grouped list; completed
              // behind the toggle, also grouped.
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (active.isNotEmpty) ...[
                        KuberSectionHeader(title: context.l10n.activeLoans),
                        KuberGroup(
                          children: [
                            for (final l in active)
                              _LoanRow(loan: l, allTxns: allTxns),
                          ],
                        ),
                      ],
                      if (completed.isNotEmpty) ...[
                        const SizedBox(height: KuberSpace.lg),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: LoansCompletedToggle(
                            count: completed.length,
                            expanded: showCompleted,
                            onToggle: () => setState(
                              () => _showCompleted = !_showCompleted,
                            ),
                          ),
                        ),
                        if (showCompleted) ...[
                          const SizedBox(height: KuberSpace.md),
                          KuberGroup(
                            children: [
                              for (final l in completed)
                                _LoanRow(loan: l, allTxns: allTxns),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: KuberExtendedFab.clearance),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoanRow extends StatelessWidget {
  final Loan loan;
  final List<Transaction> allTxns;

  const _LoanRow({required this.loan, required this.allTxns});

  @override
  Widget build(BuildContext context) {
    return LoanCard(
      name: loan.name,
      lenderLabel: [
        loan.lenderName,
        if (loan.referenceNumber?.isNotEmpty ?? false) loan.referenceNumber,
      ].whereType<String>().join(' · '),
      icon: _loanTypeIcon(loan.loanType),
      iconColor: _loanTypeColor(context, loan.loanType),
      principal: loan.principalAmount,
      paid: calc.computeTotalPaid(loan.uid, allTxns),
      outstanding: calc
          .computeRemaining(loan, allTxns)
          .clamp(0, double.infinity)
          .toDouble(),
      progress: calc.computeProgress(loan, allTxns),
      emi: loan.emiAmount,
      interestRate: loan.interestRate,
      nextDue: calc.computeNextDueDate(loan),
      isCompleted: loan.isCompleted,
      onTap: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => LoanDetailSheet(loan: loan),
        );
      },
    );
  }
}

IconData _loanTypeIcon(String type) {
  return switch (type) {
    'home' => Icons.home_work_outlined,
    'vehicle' => Icons.directions_car_filled_outlined,
    'education' => Icons.school_outlined,
    'personal' => Icons.person_outline_rounded,
    _ => Icons.account_balance_outlined,
  };
}

// Brand-stable loan-type accents. context.kuberMoney.expense / context.kuberMoney.income clash with the
// semantic meaning those colors carry elsewhere (overdue / income), so we
// pin per-type accents that read as identity instead of state.
Color _loanTypeColor(BuildContext context, String type) {
  // Identity colours from the categorical palette (no raw hex).
  final c = context.kuberChart.categorical;
  return switch (type) {
    'vehicle' => c[2],
    'personal' => c[6],
    'education' => c[5],
    _ => Theme.of(context).colorScheme.primary,
  };
}
