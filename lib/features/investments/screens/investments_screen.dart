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
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/investment.dart';
import '../providers/investment_provider.dart';
import '../utils/investment_calculations.dart' as calc;
import '../widgets/investment_detail_sheet.dart';
import '../widgets/investment_widgets.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(
      infoSeenProvider(PrefsKeys.seenInfoInvestments),
      (prev, next) {
        if (next.hasValue && next.value == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            KuberInfoBottomSheet.show(context, InfoConstants.investments);
            ref
                .read(infoSeenProvider(PrefsKeys.seenInfoInvestments).notifier)
                .markSeen();
          });
        }
      },
    );

    final cs = Theme.of(context).colorScheme;
    final investmentsAsync = ref.watch(investmentListProvider);
    final txnsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      body: investmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
        ),
        data: (investments) {
          final allTxns = txnsAsync.valueOrNull ?? [];
          final invested = calc.totalInvestedAll(investments, allTxns);
          final currentValue = calc.totalCurrentValueAll(investments);
          final gainLoss = currentValue - invested;
          final gainLossPercent = invested > 0
              ? gainLoss / invested * 100
              : 0.0;
          final allocation = _assetAllocation(context, investments);

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  showHome: true,
                  title: '',
                  infoConfig: InfoConstants.investments,
                ),
              ),
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Investments',
                  description:
                      '',
                  actionTooltip: 'Add Investment',
                  onAction: () => context.push('/investments/add'),
                ),
              ),
              if (investments.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    0,
                    KuberSpacing.lg,
                    KuberSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: PortfolioHero(
                      currentValue: currentValue,
                      invested: invested,
                      gainLoss: gainLoss,
                      gainLossPercent: gainLossPercent,
                    ),
                  ),
                ),
                if (allocation.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      KuberSpacing.lg,
                      0,
                      KuberSpacing.lg,
                      KuberSpacing.lg,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AssetAllocationStrip(slices: allocation),
                    ),
                  ),
              ],
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
              if (investments.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: _SectionHeader(label: 'ALL INVESTMENTS'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: investments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: KuberSpacing.sm),
                    itemBuilder: (_, i) => _InvestmentRow(
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

  static List<AssetSlice> _assetAllocation(
    BuildContext context,
    List<Investment> investments,
  ) {
    final totals = <String, double>{};
    for (final inv in investments) {
      totals[_assetLabel(inv.investmentType)] =
          (totals[_assetLabel(inv.investmentType)] ?? 0) +
          (inv.currentValue ?? 0);
    }
    final slices =
        totals.entries
            .where((e) => e.value > 0)
            .map(
              (e) => AssetSlice(
                label: e.key,
                color: _assetColor(context, e.key),
                value: e.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return slices;
  }
}

class _InvestmentRow extends ConsumerWidget {
  final Investment investment;
  final List<Transaction> allTxns;

  const _InvestmentRow({required this.investment, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = _assetLabel(investment.investmentType);
    final fmt = ref.watch(formatterProvider);
    return InvestmentCard(
      name: investment.name,
      assetTypeLabel: label.toUpperCase(),
      icon: _investmentIcon(investment.investmentType),
      iconColor: _assetColor(context, label),
      quantityLabel: investment.autoDebit && investment.sipAmount != null
          ? 'SIP ${fmt.formatCurrency(investment.sipAmount!)}'
          : null,
      currentValue: investment.currentValue ?? 0,
      gainLossPercent: calc.computeGainLossPercent(investment, allTxns),
      onTap: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => InvestmentDetailSheet(investment: investment),
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

String _assetLabel(String type) {
  return switch (type) {
    'sip' => 'SIP',
    'mutual_fund' => 'Mutual Fund',
    'stocks' => 'Stocks',
    'crypto' => 'Crypto',
    'trading' => 'Trading',
    _ => 'Other',
  };
}

IconData _investmentIcon(String type) {
  return switch (type) {
    'sip' => Icons.savings_outlined,
    'mutual_fund' => Icons.pie_chart_outline_rounded,
    'stocks' => Icons.show_chart_rounded,
    'crypto' => Icons.currency_bitcoin_rounded,
    'trading' => Icons.candlestick_chart_rounded,
    _ => Icons.account_balance_wallet_outlined,
  };
}

// Brand-stable asset-class palette (intentionally not theme-derived, so the
// allocation strip and per-card accents stay recognizable across themes).
Color _assetColor(BuildContext context, String label) {
  return switch (label) {
    'Stocks' => const Color(0xFF818CF8),
    'Mutual Fund' => const Color(0xFFA855F7),
    'SIP' => const Color(0xFF22C55E),
    'Crypto' => const Color(0xFF14B8A6),
    'Trading' => const Color(0xFFF59E0B),
    _ => Theme.of(context).colorScheme.onSurfaceVariant,
  };
}
