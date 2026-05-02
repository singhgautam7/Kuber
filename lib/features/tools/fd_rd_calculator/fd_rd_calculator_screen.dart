import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class FdRdCalculatorScreen extends ConsumerStatefulWidget {
  const FdRdCalculatorScreen({super.key});

  @override
  ConsumerState<FdRdCalculatorScreen> createState() =>
      _FdRdCalculatorScreenState();
}

class _FdRdCalculatorScreenState extends ConsumerState<FdRdCalculatorScreen> {
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  int _typeIndex = 0; // 0 = FD, 1 = RD
  int _durationUnitIndex = 0; // 0 = Years, 1 = Months
  int _compoundingIndex = 0; // 0 = Monthly, 1 = Quarterly, 2 = Yearly

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  ({double maturity, double principal, double interest})? _compute() {
    final p = double.tryParse(_principalCtrl.text.replaceAll(',', ''));
    final rate = double.tryParse(_rateCtrl.text);
    final duration = double.tryParse(_durationCtrl.text);
    if (p == null || rate == null || duration == null) return null;
    if (p <= 0 || rate <= 0 || duration <= 0) return null;

    final months = _durationUnitIndex == 0 ? duration * 12 : duration;
    final years = months / 12;
    final r = rate / 100;

    if (_typeIndex == 0) {
      // FD: A = P * (1 + r/n)^(n*t)
      final n = [12, 4, 1][_compoundingIndex].toDouble();
      final maturity = p * pow(1 + r / n, n * years);
      return (maturity: maturity, principal: p, interest: maturity - p);
    } else {
      // RD: each monthly installment compounds for its remaining period
      double maturity = 0;
      final n = 12.0; // monthly compounding for RD
      for (int i = 1; i <= months.toInt(); i++) {
        final t = (months - i + 1) / 12;
        maturity += p * pow(1 + r / n, n * t);
      }
      final totalPrincipal = p * months.toInt();
      return (
        maturity: maturity,
        principal: totalPrincipal,
        interest: maturity - totalPrincipal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final result = _compute();
    final isFd = _typeIndex == 0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.fdRdCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'FD / RD Calculator',
              description: 'Fixed & recurring deposit returns',
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
                    const ToolInputLabel('DEPOSIT TYPE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolSegmentedControl(
                      labels: const ['FD', 'RD'],
                      selectedIndex: _typeIndex,
                      onChanged: (i) => setState(() => _typeIndex = i),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: isFd ? 'PRINCIPAL AMOUNT' : 'MONTHLY INSTALLMENT',
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
                    const ToolInputLabel('DURATION'),
                    const SizedBox(height: KuberSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ToolTextField(
                            controller: _durationCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Expanded(
                          child: ToolSegmentedControl(
                            labels: const ['Years', 'Months'],
                            selectedIndex: _durationUnitIndex,
                            onChanged: (i) =>
                                setState(() => _durationUnitIndex = i),
                          ),
                        ),
                      ],
                    ),
                    if (isFd) ...[
                      const SizedBox(height: KuberSpacing.lg),
                      const ToolInputLabel('COMPOUNDING'),
                      const SizedBox(height: KuberSpacing.sm),
                      ToolSegmentedControl(
                        labels: const ['Monthly', 'Quarterly', 'Yearly'],
                        selectedIndex: _compoundingIndex,
                        onChanged: (i) =>
                            setState(() => _compoundingIndex = i),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: 'Maturity Amount',
                            value: formatter.formatCurrency(result.maturity,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Principal',
                            value: formatter.formatCurrency(result.principal,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Interest Earned',
                            value: formatter.formatCurrency(result.interest,
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
