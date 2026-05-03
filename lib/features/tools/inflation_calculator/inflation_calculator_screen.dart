import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class InflationCalculatorScreen extends ConsumerStatefulWidget {
  const InflationCalculatorScreen({super.key});

  @override
  ConsumerState<InflationCalculatorScreen> createState() =>
      _InflationCalculatorScreenState();
}

class _InflationCalculatorScreenState
    extends ConsumerState<InflationCalculatorScreen> {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '6');
  final _yearsCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  ({double futureValue, double valueLost, double purchasingPower})? _compute() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    final rate = double.tryParse(_rateCtrl.text);
    final years = double.tryParse(_yearsCtrl.text);
    if (amount == null || rate == null || years == null) return null;
    if (amount <= 0 || rate <= 0 || years <= 0) return null;

    final futureValue = amount / pow(1 + rate / 100, years);
    final valueLost = amount - futureValue;
    // Future equivalent: how much you'd need in future to maintain today's purchasing power
    final purchasingPower = amount * pow(1 + rate / 100, years);
    return (
      futureValue: futureValue,
      valueLost: valueLost,
      purchasingPower: purchasingPower,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final result = _compute();
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    final years = double.tryParse(_yearsCtrl.text) ?? 0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.inflationCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Inflation Calculator',
              description: 'See how inflation erodes value',
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
                      label: 'CURRENT AMOUNT',
                      controller: _amountCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'ANNUAL INFLATION RATE',
                      controller: _rateCtrl,
                      suffix: '%',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'TIME PERIOD (YEARS)',
                      controller: _yearsCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: 'Future Value',
                            value: formatter.formatCurrency(result.futureValue,
                                symbol: currency.symbol),
                            color: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Value Lost to Inflation',
                            value: formatter.formatCurrency(result.valueLost,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Future Equivalent Needed',
                            value: formatter.formatCurrency(
                                result.purchasingPower,
                                symbol: currency.symbol),
                            valueColor: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label:
                                'Today\'s ${formatter.formatCurrency(amount, symbol: currency.symbol)} = in ${years.toInt()} yrs',
                            value: formatter.formatCurrency(result.futureValue,
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
