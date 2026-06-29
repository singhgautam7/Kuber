import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/gst_engine.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class GstCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const GstCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<GstCalculatorScreen> createState() =>
      _GstCalculatorScreenState();
}

class _GstCalculatorScreenState extends ConsumerState<GstCalculatorScreen>
    with CalculatorSupport {
  final _amountCtrl = TextEditingController();
  final _customRateCtrl = TextEditingController();
  int _mode = 0; // 0 = Add, 1 = Remove
  int _rateChip = 2; // index into _rates; last = custom
  static const _rates = [5.0, 12.0, 18.0, 28.0];

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _customRateCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'gst-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'GST calc';
  @override
  String get savePlaceholder => 'e.g. Invoice GST';

  bool get _isCustom => _rateChip == _rates.length;
  double get _rate => _isCustom ? parseNum(_customRateCtrl.text) : _rates[_rateChip];

  @override
  Map<String, dynamic> collectInputs() => {
        'amount': _amountCtrl.text,
        'mode': _mode,
        'rateChip': _rateChip,
        'customRate': _customRateCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _amountCtrl.text = json['amount']?.toString() ?? '';
    _mode = json['mode'] as int? ?? 0;
    _rateChip = json['rateChip'] as int? ?? 2;
    _customRateCtrl.text = json['customRate']?.toString() ?? '';
  }

  GstResult? _compute() {
    final amount = parseAmount(_amountCtrl.text);
    if (amount <= 0 || _rate <= 0) return null;
    return _mode == 0 ? addGst(amount, _rate) : removeGst(amount, _rate);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final amt = formatter.formatCurrency(parseAmount(_amountCtrl.text),
        symbol: currency.symbol);
    final dir = _mode == 0 ? 'add' : 'remove';
    if (r == null) return 'GST $amt';
    return '$amt $dir ${_rate.toStringAsFixed(0)}% → GST ${formatter.formatCurrency(r.gstAmount, symbol: currency.symbol)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final result = _compute();
    final half = (_rate / 2).toStringAsFixed(_rate % 2 == 0 ? 0 : 1);
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'GST Calculator',
      subtitle: 'Add or remove GST from any amount',
      infoConfig: InfoConstants.gstCalculator,
      overflowConfig: savedOverflowConfig('GST'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          const ToolInputLabel('CALCULATION TYPE'),
          const SizedBox(height: KuberSpacing.sm),
          ToolSegmentedControl(
            labels: const ['Add GST', 'Remove GST'],
            selectedIndex: _mode,
            onChanged: (i) => setState(() => _mode = i),
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _amountCtrl,
            label: 'AMOUNT',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
          ),
          const SizedBox(height: KuberSpacing.lg),
          const ToolInputLabel('GST RATE'),
          const SizedBox(height: KuberSpacing.sm),
          Wrap(
            spacing: KuberSpacing.sm,
            runSpacing: KuberSpacing.sm,
            children: [
              for (var i = 0; i < _rates.length; i++)
                _Chip(
                  label: '${_rates[i].toStringAsFixed(0)}%',
                  selected: _rateChip == i,
                  onTap: () => setState(() => _rateChip = i),
                ),
              _Chip(
                label: 'Custom',
                selected: _isCustom,
                onTap: () => setState(() => _rateChip = _rates.length),
              ),
            ],
          ),
          if (_isCustom) ...[
            const SizedBox(height: KuberSpacing.md),
            ToolTextField(
              controller: _customRateCtrl,
              label: 'CUSTOM RATE',
              suffix: '%',
              onChanged: recompute,
            ),
          ],
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToolDualHero(
                      left: HeroSide(
                        label: 'GST Amount',
                        value: money(result.gstAmount),
                        color: ToolAccents.amber,
                      ),
                      right: HeroSide(
                        label: _mode == 0 ? 'Final Amount' : 'Pre-GST Amount',
                        value: money(
                            _mode == 0 ? result.grossAmount : result.preGst),
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol(_mode == 0 ? 'Pre-GST' : 'Gross',
                          money(_mode == 0 ? result.preGst : result.grossAmount)),
                      StatCol('CGST ($half%)', money(result.cgst)),
                      StatCol('SGST ($half%)', money(result.sgst)),
                    ]),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: selected ? cs.primary : cs.outline),
        ),
        child: Text(
          label,
          style: localeFont(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
