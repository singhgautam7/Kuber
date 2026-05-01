import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class EmiCalculatorScreen extends ConsumerStatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  ConsumerState<EmiCalculatorScreen> createState() =>
      _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends ConsumerState<EmiCalculatorScreen> {
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  int _tenureIndex = 0; // 0 = Years, 1 = Months

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  ({double emi, double totalPayable, double totalInterest})? _compute() {
    final p = double.tryParse(_principalCtrl.text.replaceAll(',', ''));
    final annualRate = double.tryParse(_rateCtrl.text);
    final tenure = double.tryParse(_tenureCtrl.text);
    if (p == null || annualRate == null || tenure == null) return null;
    if (p <= 0 || annualRate <= 0 || tenure <= 0) return null;

    final n = _tenureIndex == 0 ? tenure * 12 : tenure;
    final r = annualRate / 12 / 100;
    final emi = p * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
    final totalPayable = emi * n;
    final totalInterest = totalPayable - p;
    return (emi: emi, totalPayable: totalPayable, totalInterest: totalInterest);
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
              infoConfig: InfoConstants.emiCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'EMI Calculator',
              description: 'Plan your loan repayments',
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
                      label: 'LOAN AMOUNT',
                      controller: _principalCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'ANNUAL INTEREST RATE',
                      controller: _rateCtrl,
                      suffix: '%',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('TENURE'),
                    const SizedBox(height: KuberSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ToolTextField(
                            controller: _tenureCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Expanded(
                          child: ToolSegmentedControl(
                            labels: const ['Years', 'Months'],
                            selectedIndex: _tenureIndex,
                            onChanged: (i) => setState(() => _tenureIndex = i),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: 'Monthly EMI',
                            value: formatter.formatCurrency(result.emi,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Total Interest',
                            value: formatter.formatCurrency(
                                result.totalInterest,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Total Payable',
                            value: formatter.formatCurrency(
                                result.totalPayable,
                                symbol: currency.symbol),
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
