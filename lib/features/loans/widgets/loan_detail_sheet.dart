import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../providers/loan_provider.dart';
import '../utils/loan_calculations.dart' as calc;
import 'loan_payment_sheet.dart';

class LoanDetailSheet extends ConsumerWidget {
  final Loan loan;

  const LoanDetailSheet({super.key, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final allTxns = ref.watch(transactionListProvider).valueOrNull ?? [];
    final paymentsAsync = ref.watch(loanTransactionsProvider(loan.uid));
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];

    final totalPaid = calc.computeTotalPaid(loan.uid, allTxns);
    final remaining = calc.computeRemaining(loan, allTxns);
    final progress = calc.computeProgress(loan, allTxns);
    final nextDue = calc.computeNextDueDate(loan);
    final isOverdue = nextDue != null && nextDue.isBefore(DateTime.now());

    final accountName = accounts
        .where((a) => a.id.toString() == loan.accountId)
        .map((a) => a.name)
        .firstOrNull;

    return KuberBottomSheet(
      title: loan.name,
      subtitle: loan.referenceNumber ?? loan.loanType.toUpperCase(),
      leadingIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(
          _loanTypeIcon(loan.loanType),
          size: 24,
          color: cs.onSurfaceVariant,
        ),
      ),
      actions: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Pay EMI',
                  icon: Icons.payments_outlined,
                  type: AppButtonType.primary,
                  onPressed: loan.isCompleted
                      ? null
                      : () {
                          Navigator.pop(context);
                          _openPaymentSheet(context, loan, isEmi: true);
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Pay Extra',
                  icon: Icons.add_circle_outline,
                  type: AppButtonType.normal,
                  onPressed: loan.isCompleted
                      ? null
                      : () {
                          Navigator.pop(context);
                          _openPaymentSheet(context, loan, isEmi: false);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Edit',
                  icon: Icons.edit_rounded,
                  type: AppButtonType.normal,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/loans/edit', extra: loan);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Close Loan',
                  icon: Icons.lock_outline,
                  type: AppButtonType.normal,
                  onPressed: loan.isCompleted
                      ? null
                      : () {
                          Navigator.pop(context);
                          _openClosureSheet(context, loan);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            type: AppButtonType.danger,
            fullWidth: true,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Paid',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                loan.isCompleted ? cs.tertiary : cs.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'TOTAL',
                  value: fmt.formatCurrency(loan.principalAmount),
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'PAID',
                  value: fmt.formatCurrency(totalPaid),
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'REMAINING',
                  value: fmt.formatCurrency(
                      remaining.clamp(0, double.infinity)),
                  color: remaining > 0 ? cs.error : cs.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Next EMI section
          if (!loan.isCompleted) ...[
            Text(
              'NEXT EMI DUE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fmt.formatCurrency(loan.emiAmount),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                if (nextDue != null)
                  Text(
                    DateFormat('MMM d, yyyy').format(nextDue),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? cs.error : cs.primary,
                    ),
                  ),
              ],
            ),
            if (loan.autoAddTransaction && accountName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.circle, size: 6, color: cs.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Auto-pay via $accountName',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
          ],

          // Interest info
          if (loan.interestRate != null) ...[
            Row(
              children: [
                Icon(Icons.percent, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'INTEREST RATE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  '${loan.interestRate!.toStringAsFixed(2)}% p.a.${loan.rateType != null ? ' (${loan.rateType})' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Notes
          if (loan.notes != null && loan.notes!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOTES',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loan.notes!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Payment history
          Text(
            'PAYMENT HISTORY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          paymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (payments) {
              if (payments.isEmpty) {
                return Text(
                  'No payments recorded',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                );
              }
              final display = payments.take(5).toList();
              return Column(
                children: display.map((t) => _PaymentRow(transaction: t)).toList(),
              );
            },
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'CREATED ${DateFormat('MMM d, yyyy').format(loan.createdAt).toUpperCase()}',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPaymentSheet(BuildContext context, Loan loan,
      {required bool isEmi}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LoanPaymentSheet(loan: loan, isEmi: isEmi),
      );
    });
  }

  void _openClosureSheet(BuildContext context, Loan loan) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            LoanPaymentSheet(loan: loan, isEmi: false, isClosure: true),
      );
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Delete Loan?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'This will delete the loan and ALL linked payment transactions. This cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          AppButton(
            label: 'Delete',
            type: AppButtonType.danger,
            onPressed: () {
              ref.read(loanListProvider.notifier).deleteLoan(loan);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
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

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PaymentRow extends ConsumerWidget {
  final Transaction transaction;

  const _PaymentRow({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);

    final label = transaction.name.startsWith('EMI')
        ? 'EMI Paid'
        : transaction.name.startsWith('Extra')
            ? 'Extra Payment'
            : 'Loan Closure';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: cs.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(transaction.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            fmt.formatCurrency(transaction.amount),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
