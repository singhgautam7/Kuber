import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
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
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
        ),
        data: (loans) {
          final allTxns = txnsAsync.valueOrNull ?? [];
          final active = loans.where((l) => !l.isCompleted).toList();
          final completed = loans.where((l) => l.isCompleted).toList();
          final totalPrincipal = loans.fold<double>(
            0,
            (sum, l) => sum + l.principalAmount,
          );
          final totalPaid = calc.totalPaidAllLoans(loans, allTxns);
          final totalOutstanding = calc.totalOutstanding(loans, allTxns);
          final nextDue = active
              .map(calc.computeNextDueDate)
              .whereType<DateTime>()
              .fold<DateTime?>(
                null,
                (a, b) => a == null || b.isBefore(a) ? b : a,
              );

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  showHome: true,
                  title: '',
                  infoConfig: InfoConstants.loans,
                ),
              ),
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Loans',
                  description:
                      'Track your EMIs, outstanding balances and repayment progress.',
                  actionTooltip: 'Add Loan',
                  onAction: () => context.push('/loans/add'),
                ),
              ),
              if (loans.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    0,
                    KuberSpacing.lg,
                    KuberSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LoansHero(
                      totalPrincipal: totalPrincipal,
                      totalPaid: totalPaid,
                      totalOutstanding: totalOutstanding,
                      activeCount: active.length,
                      nextDue: nextDue,
                    ),
                  ),
                ),
              if (loans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.account_balance_outlined,
                    title: 'No loans added',
                    description: 'Tap + to track your first loan EMI',
                    actionLabel: 'Add Loan',
                    onAction: () => context.push('/loans/add'),
                  ),
                ),
              if (active.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: _SectionHeader(label: 'ACTIVE LOANS'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: KuberSpacing.sm),
                    itemBuilder: (_, i) =>
                        _LoanRow(loan: active[i], allTxns: allTxns),
                  ),
                ),
              ],
              if (completed.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LoansCompletedToggle(
                      count: completed.length,
                      expanded: _showCompleted,
                      onToggle: () =>
                          setState(() => _showCompleted = !_showCompleted),
                    ),
                  ),
                ),
                if (_showCompleted)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpacing.lg,
                    ),
                    sliver: SliverList.separated(
                      itemCount: completed.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: KuberSpacing.sm),
                      itemBuilder: (_, i) =>
                          _LoanRow(loan: completed[i], allTxns: allTxns),
                    ),
                  ),
              ],
              SliverToBoxAdapter(
                child: SizedBox(height: navBarBottomPadding(context)),
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
      icon: loan.icon != null
          ? IconMapper.fromString(loan.icon!)
          : _loanTypeIcon(loan.loanType),
      iconColor: loan.colorValue != null
          ? Color(loan.colorValue!)
          : _loanTypeColor(context, loan.loanType),
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        KuberSpacing.sm,
        KuberSpacing.lg,
        KuberSpacing.md,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
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

// Brand-stable loan-type accents. cs.error / cs.tertiary clash with the
// semantic meaning those colors carry elsewhere (overdue / income), so we
// pin per-type accents that read as identity instead of state.
Color _loanTypeColor(BuildContext context, String type) {
  return switch (type) {
    'home' => Theme.of(context).colorScheme.primary,
    'vehicle' => const Color(0xFF14B8A6),
    'personal' => const Color(0xFFA855F7),
    'education' => const Color(0xFFF59E0B),
    _ => Theme.of(context).colorScheme.primary,
  };
}
