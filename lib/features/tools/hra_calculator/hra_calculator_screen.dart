import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class HraCalculatorScreen extends ConsumerStatefulWidget {
  const HraCalculatorScreen({super.key});

  @override
  ConsumerState<HraCalculatorScreen> createState() =>
      _HraCalculatorScreenState();
}

class _HraCalculatorScreenState extends ConsumerState<HraCalculatorScreen> {
  final _basicCtrl = TextEditingController();
  final _hraCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  int _cityIndex = 0; // 0 = Metro, 1 = Non-Metro

  @override
  void dispose() {
    _basicCtrl.dispose();
    _hraCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  ({
    double exemption,
    double taxableHra,
    double rule1,
    double rule2,
    double rule3,
  })? _compute() {
    final basic = double.tryParse(_basicCtrl.text.replaceAll(',', ''));
    final hra = double.tryParse(_hraCtrl.text.replaceAll(',', ''));
    final rent = double.tryParse(_rentCtrl.text.replaceAll(',', ''));
    if (basic == null || hra == null || rent == null) return null;
    if (basic <= 0 || hra <= 0 || rent <= 0) return null;

    final rule1 = hra; // HRA actually received
    final rule2 = rent - basic * 0.1; // Rent - 10% of basic
    final rule3 = basic * (_cityIndex == 0 ? 0.5 : 0.4); // 50%/40% of basic

    final exemption = [rule1, rule2, rule3]
        .reduce((a, b) => a < b ? a : b)
        .clamp(0, double.infinity);
    final taxableHra = hra - exemption;

    return (
      exemption: exemption * 12, // annual
      taxableHra: taxableHra * 12, // annual
      rule1: rule1,
      rule2: rule2.clamp(0, double.infinity),
      rule3: rule3,
    );
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
              infoConfig: InfoConstants.hraCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'HRA Exemption',
              description: 'Calculate HRA tax exemption',
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
                      label: 'BASIC SALARY (MONTHLY)',
                      controller: _basicCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'HRA RECEIVED (MONTHLY)',
                      controller: _hraCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'ACTUAL RENT PAID (MONTHLY)',
                      controller: _rentCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('CITY TYPE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolSegmentedControl(
                      labels: const ['METRO', 'NON-METRO'],
                      selectedIndex: _cityIndex,
                      onChanged: (i) => setState(() => _cityIndex = i),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: 'HRA Exemption (Annual)',
                            value: formatter.formatCurrency(result.exemption,
                                symbol: currency.symbol),
                            color: cs.tertiary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Taxable HRA (Annual)',
                            value: formatter.formatCurrency(result.taxableHra,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Rule 1 — HRA Received',
                            value: formatter.formatCurrency(result.rule1,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Rule 2 — Rent − 10% Basic',
                            value: formatter.formatCurrency(result.rule2,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label:
                                'Rule 3 — ${_cityIndex == 0 ? '50' : '40'}% of Basic',
                            value: formatter.formatCurrency(result.rule3,
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
