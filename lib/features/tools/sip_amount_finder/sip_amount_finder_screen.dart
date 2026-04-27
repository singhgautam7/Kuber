import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class SipAmountFinderScreen extends ConsumerStatefulWidget {
  const SipAmountFinderScreen({super.key});

  @override
  ConsumerState<SipAmountFinderScreen> createState() =>
      _SipAmountFinderScreenState();
}

class _SipAmountFinderScreenState
    extends ConsumerState<SipAmountFinderScreen> {
  final _goalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _periodCtrl = TextEditingController();
  int _periodIndex = 0; // 0 = Years, 1 = Months

  @override
  void dispose() {
    _goalCtrl.dispose();
    _rateCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  ({double sip, double totalInvested, double returns})? _compute() {
    final goal = double.tryParse(_goalCtrl.text);
    final annualRate = double.tryParse(_rateCtrl.text);
    final period = double.tryParse(_periodCtrl.text);
    if (goal == null || annualRate == null || period == null) return null;
    if (goal <= 0 || annualRate <= 0 || period <= 0) return null;

    final n = _periodIndex == 0 ? period * 12 : period;
    final r = annualRate / 12 / 100;
    final sip = goal * r / ((pow(1 + r, n) - 1) * (1 + r));
    final totalInvested = sip * n;
    final returns = goal - totalInvested;
    return (sip: sip, totalInvested: totalInvested, returns: returns);
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
              title: 'SIP Amount Finder',
              showBack: true,
              infoConfig: InfoConstants.sipAmountFinder,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'SIP Amount Finder',
              description: 'Find your required monthly SIP',
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
                      label: 'GOAL AMOUNT',
                      controller: _goalCtrl,
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
                      : [
                          ToolHeroResult(
                            label: 'Required Monthly SIP',
                            value: formatter.formatCurrency(result.sip,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Goal Amount',
                            value: formatter.formatCurrency(
                                double.tryParse(_goalCtrl.text) ?? 0,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Total Invested',
                            value: formatter.formatCurrency(
                                result.totalInvested,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Estimated Returns',
                            value: formatter.formatCurrency(result.returns,
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
