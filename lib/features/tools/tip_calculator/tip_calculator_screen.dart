import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class TipCalculatorScreen extends ConsumerStatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  ConsumerState<TipCalculatorScreen> createState() =>
      _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends ConsumerState<TipCalculatorScreen> {
  final _billCtrl = TextEditingController();
  final _tipPctCtrl = TextEditingController(text: '10');
  double _tipPercent = 10;

  @override
  void dispose() {
    _billCtrl.dispose();
    _tipPctCtrl.dispose();
    super.dispose();
  }

  void _onSliderChanged(double v) {
    setState(() {
      _tipPercent = v;
      _tipPctCtrl.text = v.toStringAsFixed(0);
    });
  }

  void _onTextChanged(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed >= 0 && parsed <= 100) {
      setState(() => _tipPercent = parsed);
    }
  }

  ({double tip, double total})? _compute() {
    final bill = double.tryParse(_billCtrl.text.replaceAll(',', ''));
    if (bill == null || bill <= 0) return null;
    final tip = bill * _tipPercent / 100;
    return (tip: tip, total: bill + tip);
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
              infoConfig: InfoConstants.tipCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Tip Calculator',
              description: 'Calculate tips quickly',
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
                      label: 'BILL AMOUNT',
                      controller: _billCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('TIP PERCENTAGE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolTextField(
                      controller: _tipPctCtrl,
                      suffix: '%',
                      onChanged: _onTextChanged,
                    ),
                    Slider(
                      value: _tipPercent.clamp(0, 100),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: cs.primary,
                      inactiveColor: cs.outline,
                      label: '${_tipPercent.toStringAsFixed(0)}%',
                      onChanged: _onSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0%',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                        Text('100%',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
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
                            label: 'Total Amount',
                            value: formatter.formatCurrency(result.total,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Tip Amount',
                            value: formatter.formatCurrency(result.tip,
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
