import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/investment.dart';
import '../providers/investment_provider.dart';
import '../utils/investment_calculations.dart' as calc;
import 'add_contribution_sheet.dart';

class InvestmentDetailSheet extends ConsumerStatefulWidget {
  final Investment investment;

  const InvestmentDetailSheet({super.key, required this.investment});

  @override
  ConsumerState<InvestmentDetailSheet> createState() =>
      _InvestmentDetailSheetState();
}

class _InvestmentDetailSheetState
    extends ConsumerState<InvestmentDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final allTxns = ref.watch(transactionListProvider).valueOrNull ?? [];

    // Watch the live list so the sheet updates when currentValue changes
    final liveList = ref.watch(investmentListProvider).valueOrNull ?? [];
    final investment = liveList
            .where((i) => i.uid == widget.investment.uid)
            .firstOrNull ??
        widget.investment;

    final contributionsAsync =
        ref.watch(investmentTransactionsProvider(investment.uid));

    final totalInvested =
        calc.computeTotalInvested(investment.uid, allTxns);
    final gainLoss = calc.computeGainLoss(investment, allTxns);
    final gainLossPercent =
        calc.computeGainLossPercent(investment, allTxns);
    final isGain = gainLoss >= 0;
    final hasCurrentValue = investment.currentValue != null;

    return KuberBottomSheet(
      title: investment.name,
      subtitle: _investmentTypeLabel(investment.investmentType),
      leadingIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(
          _investmentTypeIcon(investment.investmentType),
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
                  label: 'Add Contribution',
                  icon: Icons.add_circle_outline,
                  type: AppButtonType.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    _openContributionSheet(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Update Value',
                  icon: Icons.edit_outlined,
                  type: AppButtonType.normal,
                  onPressed: () =>
                      _showUpdateValueDialog(context, ref),
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
                    context.push('/investments/edit', extra: investment);
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
                  label: 'INVESTED',
                  value: fmt.formatCurrency(totalInvested),
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'CURRENT',
                  value: hasCurrentValue
                      ? fmt.formatCurrency(investment.currentValue!)
                      : '—',
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'GAIN/LOSS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasCurrentValue
                          ? '${isGain ? '+' : ''}${fmt.formatCurrency(gainLoss)}'
                          : '—',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: hasCurrentValue
                            ? (isGain ? cs.tertiary : cs.error)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    if (hasCurrentValue)
                      Text(
                        '${isGain ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isGain ? cs.tertiary : cs.error,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // SIP Configuration
          if (investment.autoDebit) ...[
            const SizedBox(height: 24),
            Text(
              'SIP CONFIGURATION',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            if (investment.sipAmount != null)
              _InfoRow(
                icon: Icons.savings_outlined,
                label: 'Monthly SIP',
                value:
                    '${fmt.formatCurrency(investment.sipAmount!)} on ${investment.sipDate}th',
              ),
            if (investment.accountId != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Source Account',
                value: investment.accountId!,
              ),
            ],
          ],

          // Notes
          if (investment.notes != null && investment.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
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
                        'STRATEGY NOTES',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        investment.notes!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Contribution history
          Text(
            'CONTRIBUTION HISTORY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          contributionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (contributions) {
              if (contributions.isEmpty) {
                return Text(
                  'No contributions recorded',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                );
              }
              final display = contributions.take(5).toList();
              return Column(
                children: display
                    .map((t) => _ContributionRow(transaction: t))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'CREATED ${DateFormat('MMM d, yyyy').format(investment.createdAt).toUpperCase()}',
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

  void _openContributionSheet(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddContributionSheet(investment: widget.investment),
      );
    });
  }

  void _showUpdateValueDialog(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(
      text: widget.investment.currentValue?.toStringAsFixed(0) ?? '',
    );
    final symbol = ref.read(currencyProvider).symbol;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Update Current Value',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 18, color: cs.onSurface),
          decoration: InputDecoration(
            prefixText: '$symbol ',
            prefixStyle: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            hintText: '0',
            hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          AppButton(
            label: 'Update',
            type: AppButtonType.primary,
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              ref
                  .read(investmentListProvider.notifier)
                  .updateCurrentValue(widget.investment, value);
              Navigator.pop(ctx);
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
        title: Text('Delete Investment?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'This will delete the investment and ALL linked contribution transactions. This cannot be undone.',
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
              ref
                  .read(investmentListProvider.notifier)
                  .deleteInvestment(widget.investment);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static IconData _investmentTypeIcon(String type) {
    switch (type) {
      case 'sip':
        return Icons.savings_outlined;
      case 'mutual_fund':
        return Icons.pie_chart_outline;
      case 'stocks':
        return Icons.candlestick_chart_outlined;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'trading':
        return Icons.trending_up;
      case 'real_estate':
        return Icons.apartment_outlined;
      default:
        return Icons.show_chart;
    }
  }

  static String _investmentTypeLabel(String type) {
    switch (type) {
      case 'sip':
        return 'SIP';
      case 'mutual_fund':
        return 'MUTUAL FUND';
      case 'stocks':
        return 'STOCKS';
      case 'crypto':
        return 'CRYPTO';
      case 'trading':
        return 'TRADING';
      case 'real_estate':
        return 'REAL ESTATE';
      default:
        return 'OTHER';
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ContributionRow extends ConsumerWidget {
  final Transaction transaction;

  const _ContributionRow({required this.transaction});

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
                  'Contribution',
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
