import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class PpfCalculatorScreen extends ConsumerStatefulWidget {
  const PpfCalculatorScreen({super.key});

  @override
  ConsumerState<PpfCalculatorScreen> createState() =>
      _PpfCalculatorScreenState();
}

class _PpfCalculatorScreenState extends ConsumerState<PpfCalculatorScreen> {
  final _investmentCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '7.1');
  int _durationYears = 15; // 15, 20, or 25

  @override
  void dispose() {
    _investmentCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  ({double maturity, double totalInvested, double totalInterest})? _compute() {
    final yearly =
        double.tryParse(_investmentCtrl.text.replaceAll(',', ''));
    final rate = double.tryParse(_rateCtrl.text);
    if (yearly == null || rate == null) return null;
    if (yearly <= 0 || rate <= 0) return null;

    double balance = 0;
    // First 15 years: invest + compound annually
    for (int y = 1; y <= 15; y++) {
      balance = (balance + yearly) * (1 + rate / 100);
    }
    // Extension blocks (no new investment after year 15)
    if (_durationYears > 15) {
      for (int y = 16; y <= _durationYears; y++) {
        balance = balance * (1 + rate / 100);
      }
    }

    final totalInvested = yearly * 15;
    return (
      maturity: balance,
      totalInvested: totalInvested,
      totalInterest: balance - totalInvested,
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
              infoConfig: InfoConstants.ppfCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'PPF Calculator',
              description: 'Public Provident Fund returns',
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
                      label: 'YEARLY INVESTMENT',
                      controller: _investmentCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.xs),
                    Text(
                      'Max ${currency.symbol}1,50,000 per year',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolTextField(
                      label: 'INTEREST RATE',
                      controller: _rateCtrl,
                      suffix: '%',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('DURATION'),
                    const SizedBox(height: KuberSpacing.sm),
                    Row(
                      children: [15, 20, 25].map((years) {
                        final selected = _durationYears == years;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: KuberSpacing.xs),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _durationYears = years),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    vertical: KuberSpacing.sm),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? cs.primary
                                      : cs.surfaceContainerHigh,
                                  borderRadius:
                                      BorderRadius.circular(KuberRadius.md),
                                  border: Border.all(
                                    color:
                                        selected ? cs.primary : cs.outline,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$years yrs',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : cs.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
                            label: 'Total Invested',
                            value: formatter.formatCurrency(
                                result.totalInvested,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Total Interest',
                            value: formatter.formatCurrency(
                                result.totalInterest,
                                symbol: currency.symbol),
                            valueColor: cs.tertiary,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Duration',
                            value: '$_durationYears Years',
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
