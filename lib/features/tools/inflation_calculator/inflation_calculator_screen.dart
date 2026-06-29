import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/inflation_engine.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class InflationCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const InflationCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<InflationCalculatorScreen> createState() =>
      _InflationCalculatorScreenState();
}

class _InflationCalculatorScreenState
    extends ConsumerState<InflationCalculatorScreen> with CalculatorSupport {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'inflation-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Inflation impact';
  @override
  String get savePlaceholder => 'e.g. Retirement target';

  int get _years => parseNum(_yearsCtrl.text).round();

  @override
  Map<String, dynamic> collectInputs() => {
        'amount': _amountCtrl.text,
        'rate': _rateCtrl.text,
        'years': _yearsCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _amountCtrl.text = json['amount']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _yearsCtrl.text = json['years']?.toString() ?? '';
  }

  InflationResult? _compute() {
    final amount = parseAmount(_amountCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    if (amount <= 0 || rate <= 0 || _years <= 0) return null;
    return computeInflation(amount, rate, _years);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final amt = formatter.formatCurrency(parseAmount(_amountCtrl.text),
        symbol: currency.symbol);
    if (r == null) return 'Inflation $amt';
    return '$amt @ ${_rateCtrl.text}% / ${_years}y → ${formatter.formatCurrency(r.futureValueRequired, symbol: currency.symbol)} needed';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final result = _compute();
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'Inflation',
      subtitle: 'What your money will be worth in the future',
      infoConfig: InfoConstants.inflationCalculator,
      overflowConfig: savedOverflowConfig('inflation'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      isSavedView: hasSaved,
      isModified: isModified,
      onUpdate: updateSaved,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _amountCtrl,
            label: 'CURRENT AMOUNT',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 10000,
            max: 50000000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _rateCtrl,
            label: 'INFLATION RATE',
            suffix: '%',
            helper: 'Long-term average for India ≈ 6%',
            onChanged: recompute,
            min: 1,
            max: 15,
            divisions: 140,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _yearsCtrl,
            label: 'YEARS',
            suffix: 'years',
            onChanged: recompute,
            min: 1,
            max: 40,
            divisions: 39,
          ),
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : ToolDualHero(
                  left: HeroSide(
                    label: 'Future Value Required',
                    value: money(result.futureValueRequired),
                    color: ToolAccents.pink,
                    sub: "to keep today's purchasing power",
                  ),
                  right: HeroSide(
                    label: "Real Value of Today's ₹",
                    value: money(result.realValueOfToday),
                    color: cs.onSurfaceVariant,
                    sub: 'what it buys after $_years years',
                  ),
                ),
        ),
        if (result != null)
          ToolSection(
            title: 'Purchasing power over time',
            subtitle: 'Future value required vs real value',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Future value required',
                    points: result.futureSeries,
                    color: ToolAccents.pink),
                ChartSeries(
                    name: 'Real value of money',
                    points: result.realSeries,
                    color: cs.primary,
                    dashed: true),
              ],
              xLabels: [
                for (var i = 0; i < result.futureSeries.length; i++) 'Y$i',
              ],
            ),
          ),
      ],
    );
  }
}
