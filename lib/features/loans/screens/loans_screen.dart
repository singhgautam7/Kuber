import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/info_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../providers/loan_provider.dart';
import '../utils/loan_calculations.dart' as calc;
import '../widgets/loan_detail_sheet.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  bool _showCompleted = false;

  @override


  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoLoans), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.loans);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoLoans).notifier).markSeen();
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
          child: Text('Error: $e',
              style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        ),
        data: (loans) {
          final allTxns = txnsAsync.valueOrNull ?? [];
          final active = loans.where((l) => !l.isCompleted).toList();
          final completed = loans.where((l) => l.isCompleted).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: 'Loans',
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

              // Summary cards
              if (loans.isNotEmpty)
                SliverToBoxAdapter(
                  child: _SummaryRow(loans: loans, allTxns: allTxns),
                ),

              // Empty state
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

              // Active loans
              if (active.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(label: 'ACTIVE LOANS'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _LoanCard(loan: active[i], allTxns: allTxns),
                  ),
                ),
              ],

              // Completed loans (collapsible)
              if (completed.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _CompletedHeader(
                    count: completed.length,
                    isExpanded: _showCompleted,
                    onToggle: () =>
                        setState(() => _showCompleted = !_showCompleted),
                  ),
                ),
                if (_showCompleted)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.separated(
                      itemCount: completed.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) =>
                          _LoanCard(loan: completed[i], allTxns: allTxns),
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

class _SummaryRow extends ConsumerWidget {
  final List<Loan> loans;
  final List<Transaction> allTxns;

  const _SummaryRow({required this.loans, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final outstanding = calc.totalOutstanding(loans, allTxns);
    final totalPaid = calc.totalPaidAllLoans(loans, allTxns);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'TOTAL OUTSTANDING',
              amount: fmt.formatCurrency(outstanding),
              color: cs.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              label: 'TOTAL PAID',
              amount: fmt.formatCurrency(totalPaid),
              color: cs.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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

class _CompletedHeader extends StatelessWidget {
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CompletedHeader({
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            Text(
              'COMPLETED LOANS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: cs.tertiary,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanCard extends ConsumerWidget {
  final Loan loan;
  final List<Transaction> allTxns;

  const _LoanCard({required this.loan, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);

    final totalPaid = calc.computeTotalPaid(loan.uid, allTxns);
    final remaining = calc.computeRemaining(loan, allTxns);
    final progress = calc.computeProgress(loan, allTxns);
    final nextDue = calc.computeNextDueDate(loan);
    final isOverdue =
        nextDue != null && nextDue.isBefore(DateTime.now());

    return GestureDetector(
      onTap: () => _openDetailSheet(context, loan),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: icon + name + principal
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _loanTypeIcon(loan.loanType),
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          loan.lenderName,
                          if (loan.referenceNumber != null &&
                              loan.referenceNumber!.isNotEmpty)
                            loan.referenceNumber,
                        ].join(' · '),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PRINCIPAL',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.formatCurrency(loan.principalAmount),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% Completed',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${fmt.formatCurrency(totalPaid)} / ${fmt.formatCurrency(loan.principalAmount)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  loan.isCompleted ? cs.tertiary : cs.primary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'REMAINING',
                    value: fmt.formatCurrency(
                        remaining.clamp(0, double.infinity)),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'MONTHLY EMI',
                    value: fmt.formatCurrency(loan.emiAmount),
                  ),
                ),
                if (loan.interestRate != null)
                  Expanded(
                    child: _StatItem(
                      label: 'INTEREST',
                      value: '${loan.interestRate!.toStringAsFixed(2)}%',
                    ),
                  ),
                Expanded(
                  child: loan.isCompleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.tertiary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'COMPLETED',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: cs.tertiary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        )
                      : _StatItem(
                          label: 'NEXT DUE',
                          value: nextDue != null
                              ? DateFormat('MMM d').format(nextDue)
                              : '—',
                          valueColor:
                              isOverdue ? cs.error : cs.primary,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context, Loan loan) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoanDetailSheet(loan: loan),
    );
  }

  static IconData _loanTypeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'vehicle':
        return Icons.directions_car_outlined;
      case 'personal':
        return Icons.work_outline;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}
