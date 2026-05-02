import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class BreakevenCalculatorScreen extends ConsumerStatefulWidget {
  const BreakevenCalculatorScreen({super.key});

  @override
  ConsumerState<BreakevenCalculatorScreen> createState() =>
      _BreakevenCalculatorScreenState();
}

class _BreakevenCalculatorScreenState
    extends ConsumerState<BreakevenCalculatorScreen> {
  final _costCtrl = TextEditingController();
  final _savingCtrl = TextEditingController();
  final _altCostCtrl = TextEditingController();

  @override
  void dispose() {
    _costCtrl.dispose();
    _savingCtrl.dispose();
    _altCostCtrl.dispose();
    super.dispose();
  }

  ({
    int breakEvenMonths,
    double savings1yr,
    double savings3yr,
    double savings5yr,
  })? _compute() {
    final cost = double.tryParse(_costCtrl.text.replaceAll(',', ''));
    final saving = double.tryParse(_savingCtrl.text.replaceAll(',', ''));
    if (cost == null || saving == null) return null;
    if (cost <= 0 || saving <= 0) return null;

    final altCost =
        double.tryParse(_altCostCtrl.text.replaceAll(',', '')) ?? 0;
    final effectiveSaving = saving + altCost;
    if (effectiveSaving <= 0) return null;

    final months = (cost / effectiveSaving).ceil();
    return (
      breakEvenMonths: months,
      savings1yr: effectiveSaving * 12 - cost,
      savings3yr: effectiveSaving * 36 - cost,
      savings5yr: effectiveSaving * 60 - cost,
    );
  }

  String _formatBreakEven(int months) {
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    final rem = months % 12;
    if (rem == 0) return '$years year${years > 1 ? 's' : ''}';
    return '$years yr${years > 1 ? 's' : ''} $rem mo';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final result = _compute();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.breakevenCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Break-even Calculator',
              description: 'How long to recover a purchase',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ToolInputCard(
                  children: [
                    ToolTextField(
                      label: 'PURCHASE COST',
                      controller: _costCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'MONTHLY SAVING / BENEFIT',
                      controller: _savingCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'ALTERNATIVE MONTHLY COST (OPTIONAL)',
                      controller: _altCostCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: 'Break-even In',
                            value: _formatBreakEven(result.breakEvenMonths),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Total Savings after 1 Year',
                            value: formatter.formatCurrency(result.savings1yr,
                                symbol: currency.symbol),
                            valueColor:
                                result.savings1yr >= 0 ? cs.tertiary : cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Total Savings after 3 Years',
                            value: formatter.formatCurrency(result.savings3yr,
                                symbol: currency.symbol),
                            valueColor: cs.tertiary,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Total Savings after 5 Years',
                            value: formatter.formatCurrency(result.savings5yr,
                                symbol: currency.symbol),
                            valueColor: cs.tertiary,
                          ),
                        ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
