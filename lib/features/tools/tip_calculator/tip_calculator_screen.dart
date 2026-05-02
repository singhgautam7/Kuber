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
  int _splitCount = 1;

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
    if (parsed != null && parsed >= 0 && parsed <= 30) {
      setState(() => _tipPercent = parsed);
    }
  }

  ({double tip, double total, double perPerson})? _compute() {
    final bill = double.tryParse(_billCtrl.text.replaceAll(',', ''));
    if (bill == null || bill <= 0) return null;
    final tip = bill * _tipPercent / 100;
    final total = bill + tip;
    return (tip: tip, total: total, perPerson: total / _splitCount);
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
                      value: _tipPercent.clamp(0, 30),
                      min: 0,
                      max: 30,
                      divisions: 30,
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
                        Text('30%',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('SPLIT BETWEEN'),
                    const SizedBox(height: KuberSpacing.sm),
                    Row(
                      children: [
                        _StepperButton(
                          icon: Icons.remove,
                          onTap: _splitCount > 1
                              ? () => setState(() => _splitCount--)
                              : null,
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        Text(
                          '$_splitCount ${_splitCount == 1 ? 'person' : 'people'}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: KuberSpacing.md),
                        _StepperButton(
                          icon: Icons.add,
                          onTap: _splitCount < 20
                              ? () => setState(() => _splitCount++)
                              : null,
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
                            label: 'Tip Amount',
                            value: formatter.formatCurrency(result.tip,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Total Bill',
                            value: formatter.formatCurrency(result.total,
                                symbol: currency.symbol),
                          ),
                          if (_splitCount > 1) ...[
                            const SizedBox(height: KuberSpacing.sm),
                            ToolStatRow(
                              label: 'Per Person',
                              value: formatter.formatCurrency(result.perPerson,
                                  symbol: currency.symbol),
                              valueColor: cs.tertiary,
                            ),
                          ],
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

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? cs.onSurface : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
