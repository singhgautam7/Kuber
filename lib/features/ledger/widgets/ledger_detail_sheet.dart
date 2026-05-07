import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/ledger.dart';
import '../providers/ledger_provider.dart';
import '../utils/ledger_calculations.dart' as calc;
import 'add_payment_sheet.dart';

class LedgerDetailSheet extends ConsumerWidget {
  final Ledger ledger;

  const LedgerDetailSheet({super.key, required this.ledger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final allTxns = ref.watch(transactionListProvider).valueOrNull ?? [];
    final paymentsAsync = ref.watch(ledgerPaymentsProvider(ledger.uid));

    final paid = calc.computePaid(ledger.uid, allTxns);
    final remaining = calc.computeRemaining(ledger, allTxns);
    final progress = calc.computeProgress(ledger, allTxns);
    final isLent = ledger.type == 'lent';
    final progressColor = isLent ? cs.tertiary : cs.error;

    final initials = _getInitials(ledger.personName);

    return KuberBottomSheet(
      title: ledger.personName,
      subtitle: isLent ? 'LENT TRANSACTION' : 'BORROWED TRANSACTION',
      leadingIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ),
      actions: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add Payment',
                  icon: Icons.payments_outlined,
                  type: AppButtonType.normal,
                  onPressed: ledger.isSettled
                      ? null
                      : () {
                          Navigator.pop(context);
                          _openPaymentSheet(context, ledger);
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Mark Settled',
                  icon: Icons.check_circle_outline,
                  type: AppButtonType.primary,
                  onPressed: ledger.isSettled
                      ? null
                      : () => _confirmSettle(context, ref),
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
                    context.push('/ledger/edit', extra: ledger);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  type: AppButtonType.danger,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'TOTAL',
                  value: fmt.formatCurrency(ledger.originalAmount),
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'PAID',
                  value: fmt.formatCurrency(paid),
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'REMAINING',
                  value: fmt.formatCurrency(remaining.clamp(0, double.infinity)),
                  color: remaining > 0 ? cs.error : cs.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REPAYMENT PROGRESS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
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
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),

          // Due date
          if (ledger.expectedDate != null) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'DUE DATE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, yyyy').format(ledger.expectedDate!),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],

          // Notes
          if (ledger.notes != null && ledger.notes!.isNotEmpty) ...[
            const SizedBox(height: 20),
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
                        ledger.notes!,
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
          ],

          const SizedBox(height: 24),

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
              return Column(
                children: payments
                    .map((t) => _PaymentRow(transaction: t, isLent: isLent))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 16),

          // Created date
          Center(
            child: Text(
              'CREATED ${DateFormat('MMM d, yyyy').format(ledger.createdAt).toUpperCase()}',
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

  void _openPaymentSheet(BuildContext context, Ledger ledger) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddPaymentSheet(ledger: ledger),
      );
    });
  }

  void _confirmSettle(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Mark as Settled?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'This will record the remaining amount as a payment and mark this entry as settled.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          AppButton(
            label: 'Settle',
            type: AppButtonType.primary,
            onPressed: () {
              ref.read(ledgerListProvider.notifier).markSettled(
                    ledger: ledger,
                    accountId: ledger.accountId,
                  );
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Delete Ledger Entry?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'This will delete the entry and ALL linked transactions. This cannot be undone.',
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
              ref.read(ledgerListProvider.notifier).deleteLedger(ledger);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
  final bool isLent;

  const _PaymentRow({required this.transaction, required this.isLent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);

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
                  isLent ? 'Payment Received' : 'Payment Made',
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
