import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class DiscountCalculatorScreen extends ConsumerStatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  ConsumerState<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState
    extends ConsumerState<DiscountCalculatorScreen> {
  final _priceCtrl = TextEditingController();
  final _discountPctCtrl = TextEditingController(text: '10');
  double _discountPercent = 10;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _discountPctCtrl.dispose();
    super.dispose();
  }

  void _onSliderChanged(double v) {
    setState(() {
      _discountPercent = v;
      _discountPctCtrl.text = v.toStringAsFixed(0);
    });
  }

  void _onTextChanged(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed >= 0 && parsed <= 90) {
      setState(() => _discountPercent = parsed);
    }
  }

  ({double discountAmount, double finalPrice})? _compute() {
    final price = double.tryParse(_priceCtrl.text);
    if (price == null || price <= 0) return null;
    final discountAmount = price * _discountPercent / 100;
    return (discountAmount: discountAmount, finalPrice: price - discountAmount);
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
              title: 'Discount Calculator',
              showBack: true,
              infoConfig: InfoConstants.discountCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Discount Calculator',
              description: 'Find the best deal',
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
                      label: 'ORIGINAL PRICE',
                      controller: _priceCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('DISCOUNT PERCENTAGE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolTextField(
                      controller: _discountPctCtrl,
                      suffix: '%',
                      onChanged: _onTextChanged,
                    ),
                    Slider(
                      value: _discountPercent.clamp(0, 90),
                      min: 0,
                      max: 90,
                      divisions: 90,
                      activeColor: cs.primary,
                      inactiveColor: cs.outline,
                      label: '${_discountPercent.toStringAsFixed(0)}%',
                      onChanged: _onSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0%',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                        Text('90%',
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
                            label: 'Final Price',
                            value: formatter.formatCurrency(result.finalPrice,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Discount Amount',
                            value:
                                '-${formatter.formatCurrency(result.discountAmount, symbol: currency.symbol)}',
                            valueColor: cs.error,
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
