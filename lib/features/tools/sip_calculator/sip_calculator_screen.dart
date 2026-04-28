import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class InvestmentReturnsCalculatorScreen extends ConsumerStatefulWidget {
  const InvestmentReturnsCalculatorScreen({super.key});

  @override
  ConsumerState<InvestmentReturnsCalculatorScreen> createState() =>
      _InvestmentReturnsCalculatorScreenState();
}

class _InvestmentReturnsCalculatorScreenState
    extends ConsumerState<InvestmentReturnsCalculatorScreen> {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _periodCtrl = TextEditingController();
  int _periodIndex = 0; // 0 = Years, 1 = Months
  int _modeIndex = 0; // 0 = Monthly SIP, 1 = One Time

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  ({double fv, double invested, double returns})? _compute() {
    final p = double.tryParse(_amountCtrl.text);
    final annualRate = double.tryParse(_rateCtrl.text);
    final period = double.tryParse(_periodCtrl.text);
    if (p == null || annualRate == null || period == null) return null;
    if (p <= 0 || annualRate <= 0 || period <= 0) return null;

    final n = _periodIndex == 0 ? period * 12 : period;
    final r = annualRate / 12 / 100;

    if (_modeIndex == 0) {
      final fv = p * ((pow(1 + r, n) - 1) / r) * (1 + r);
      final invested = p * n;
      return (fv: fv, invested: invested, returns: fv - invested);
    } else {
      final fv = p * pow(1 + r, n);
      return (fv: fv, invested: p, returns: fv - p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final result = _compute();
    final isMonthly = _modeIndex == 0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.investmentReturnsCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Investment Returns',
              description: 'Estimate SIP & lump-sum growth',
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
                    const ToolInputLabel('INVESTMENT TYPE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolSegmentedControl(
                      labels: const ['MONTHLY', 'ONE TIME'],
                      selectedIndex: _modeIndex,
                      onChanged: (i) => setState(() => _modeIndex = i),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: isMonthly
                          ? 'MONTHLY INVESTMENT'
                          : 'INVESTMENT AMOUNT',
                      controller: _amountCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'EXPECTED ANNUAL RETURN',
                      controller: _rateCtrl,
                      suffix: '%',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('TIME PERIOD'),
                    const SizedBox(height: KuberSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ToolTextField(
                            controller: _periodCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Expanded(
                          child: ToolSegmentedControl(
                            labels: const ['Years', 'Months'],
                            selectedIndex: _periodIndex,
                            onChanged: (i) => setState(() => _periodIndex = i),
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
                      : isMonthly
                          ? [
                              ToolHeroResult(
                                label: 'Estimated Returns',
                                value: formatter.formatCurrency(result.returns,
                                    symbol: currency.symbol),
                                color: cs.tertiary,
                              ),
                              const SizedBox(height: KuberSpacing.lg),
                              ToolStatRow(
                                label: 'Total Invested',
                                value: formatter.formatCurrency(result.invested,
                                    symbol: currency.symbol),
                              ),
                              const SizedBox(height: KuberSpacing.sm),
                              ToolStatRow(
                                label: 'Total Value',
                                value: formatter.formatCurrency(result.fv,
                                    symbol: currency.symbol),
                                valueColor: cs.tertiary,
                              ),
                            ]
                          : [
                              ToolHeroResult(
                                label: 'Total Value',
                                value: formatter.formatCurrency(result.fv,
                                    symbol: currency.symbol),
                                color: cs.primary,
                              ),
                              const SizedBox(height: KuberSpacing.lg),
                              ToolStatRow(
                                label: 'Estimated Returns',
                                value: formatter.formatCurrency(result.returns,
                                    symbol: currency.symbol),
                                valueColor: cs.tertiary,
                              ),
                              const SizedBox(height: KuberSpacing.sm),
                              ToolStatRow(
                                label: 'Principal',
                                value: formatter.formatCurrency(result.invested,
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
