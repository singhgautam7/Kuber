import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/info_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/investment.dart';
import '../providers/investment_provider.dart';
import '../utils/investment_calculations.dart' as calc;
import '../widgets/investment_detail_sheet.dart';

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  @override


  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoInvestments), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.investments);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoInvestments).notifier).markSeen();
        });
      }
    });

    final cs = Theme.of(context).colorScheme;
    final investmentsAsync = ref.watch(investmentListProvider);
    final txnsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      body: investmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        ),
        data: (investments) {
          final allTxns = txnsAsync.valueOrNull ?? [];

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: 'Investments',
                  infoConfig: InfoConstants.investments,
                ),
              ),
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Investments',
                  description:
                      'Track your portfolio value, contributions and growth.',
                  actionTooltip: 'Add Investment',
                  onAction: () => context.push('/investments/add'),
                ),
              ),

              // Summary grid
              if (investments.isNotEmpty)
                SliverToBoxAdapter(
                  child:
                      _SummaryGrid(investments: investments, allTxns: allTxns),
                ),

              // Empty state
              if (investments.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.show_chart,
                    title: 'No investments tracked',
                    description: 'Tap + to add your first investment',
                    actionLabel: 'Add Investment',
                    onAction: () => context.push('/investments/add'),
                  ),
                ),

              // Investment cards
              if (investments.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(label: 'ALL INVESTMENTS'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: investments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _InvestmentCard(
                      investment: investments[i],
                      allTxns: allTxns,
                    ),
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

class _SummaryGrid extends ConsumerWidget {
  final List<Investment> investments;
  final List<Transaction> allTxns;

  const _SummaryGrid({required this.investments, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final totalInvested = calc.totalInvestedAll(investments, allTxns);
    final currentValue = calc.totalCurrentValueAll(investments);
    final gainLoss = calc.totalGainLossAll(investments, allTxns);
    final gainLossPercent =
        totalInvested > 0 ? (gainLoss / totalInvested * 100) : 0.0;
    final assetCount = calc.totalAssetCount(investments);

    final isGain = gainLoss >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'TOTAL INVESTED',
                  amount: maskAmount(fmt.formatCurrency(totalInvested), isPrivate),
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'CURRENT VALUE',
                  amount: maskAmount(fmt.formatCurrency(currentValue), isPrivate),
                  color: isGain ? cs.tertiary : cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GainLossCard(
                  amount: maskAmount(fmt.formatCurrency(gainLoss.abs()), isPrivate),
                  isGain: isGain,
                  percent: gainLossPercent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'TOTAL ASSETS',
                  amount: '$assetCount Assets',
                  color: cs.onSurface,
                ),
              ),
            ],
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

class _GainLossCard extends StatelessWidget {
  final String amount;
  final bool isGain;
  final double percent;

  const _GainLossCard({
    required this.amount,
    required this.isGain,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isGain ? cs.tertiary : cs.error;
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
            'TOTAL GAIN/LOSS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${isGain ? '+' : '-'}$amount',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${isGain ? '+' : ''}${percent.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
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

class _InvestmentCard extends ConsumerWidget {
  final Investment investment;
  final List<Transaction> allTxns;

  const _InvestmentCard({required this.investment, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final totalInvested =
        calc.computeTotalInvested(investment.uid, allTxns);
    final gainLoss = calc.computeGainLoss(investment, allTxns);
    final gainLossPercent =
        calc.computeGainLossPercent(investment, allTxns);
    final isGain = gainLoss >= 0;
    final hasCurrentValue = investment.currentValue != null;

    String statusLabel;
    Color statusColor;
    if (!hasCurrentValue) {
      statusLabel = 'NOT SET';
      statusColor = cs.onSurfaceVariant;
    } else if (gainLossPercent > 10) {
      statusLabel = 'BULLISH';
      statusColor = cs.tertiary;
    } else if (gainLossPercent >= 0) {
      statusLabel = 'STABLE';
      statusColor = cs.primary;
    } else {
      statusLabel = 'LOSS';
      statusColor = cs.error;
    }

    return GestureDetector(
      onTap: () => _openDetailSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row
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
                    _investmentTypeIcon(investment.investmentType),
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
                        investment.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _investmentTypeLabel(investment.investmentType),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasCurrentValue
                          ? maskAmount(fmt.formatCurrency(investment.currentValue!), isPrivate)
                          : '—',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    if (hasCurrentValue) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${isGain ? '+' : ''}${gainLossPercent.toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isGain ? cs.tertiary : cs.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVESTED AMOUNT',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        maskAmount(fmt.formatCurrency(totalInvested), isPrivate),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InvestmentDetailSheet(investment: investment),
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
        return 'Mutual Fund';
      case 'stocks':
        return 'Stocks';
      case 'crypto':
        return 'Crypto';
      case 'trading':
        return 'Trading';
      case 'real_estate':
        return 'Real Estate';
      default:
        return 'Other';
    }
  }
}
