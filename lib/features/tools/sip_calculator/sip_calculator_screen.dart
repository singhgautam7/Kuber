import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/investment_engine.dart';
import '../engine/monthly_schedules.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';

class InvestmentReturnsCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const InvestmentReturnsCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<InvestmentReturnsCalculatorScreen> createState() =>
      _InvestmentReturnsCalculatorScreenState();
}

class _InvestmentReturnsCalculatorScreenState
    extends ConsumerState<InvestmentReturnsCalculatorScreen>
    with CalculatorSupport {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  int _type = 1; // 0 = Lumpsum, 1 = SIP
  int _scheduleMode = 0;

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'sip-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => _type == 1 ? 'Monthly SIP' : 'Lumpsum invest';
  @override
  String get savePlaceholder => 'e.g. Retirement SIP';

  int get _years => parseNum(_tenureCtrl.text).round();
  bool get _isSip => _type == 1;

  @override
  Map<String, dynamic> collectInputs() => {
        'amount': _amountCtrl.text,
        'rate': _rateCtrl.text,
        'tenure': _tenureCtrl.text,
        'type': _type,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _amountCtrl.text = json['amount']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '';
    _type = json['type'] as int? ?? 1;
  }

  InvestmentResult? _compute() {
    final amount = parseAmount(_amountCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    final years = _years;
    if (amount <= 0 || rate <= 0 || years <= 0) return null;
    return _isSip
        ? computeSip(amount, rate, years)
        : computeLumpsum(amount, rate, years);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final amt = formatter.formatCurrency(parseAmount(_amountCtrl.text),
        symbol: currency.symbol);
    final kind = _isSip ? 'SIP' : 'Lumpsum';
    if (r == null) return '$kind $amt';
    return '$kind $amt @ ${_rateCtrl.text}% for ${_years}y → ${formatter.formatCurrency(r.futureValue, symbol: currency.symbol)}';
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
      title: 'Investment Returns',
      subtitle: 'How your investment grows over the years',
      infoConfig: InfoConstants.investmentReturnsCalculator,
      overflowConfig: savedOverflowConfig('investment'),
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
            label: _isSip ? 'INVESTMENT AMOUNT (PER MONTH)' : 'INVESTMENT AMOUNT',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 500,
            max: _isSip ? 200000 : 10000000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _rateCtrl,
            label: 'EXPECTED ANNUAL RETURN',
            suffix: '%',
            onChanged: recompute,
            min: 1,
            max: 30,
            divisions: 290,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _tenureCtrl,
            label: 'TENURE',
            suffix: 'years',
            onChanged: recompute,
            min: 1,
            max: 40,
            divisions: 39,
          ),
          const SizedBox(height: KuberSpacing.lg),
          const ToolInputLabel('INVESTMENT TYPE'),
          const SizedBox(height: KuberSpacing.sm),
          ToolSegmentedControl(
            labels: const ['Lumpsum', 'SIP'],
            selectedIndex: _type,
            onChanged: (i) => setState(() => _type = i),
          ),
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToolHero(
                      label: 'Future Value',
                      value: money(result.futureValue),
                      color: cs.tertiary,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol('Total Invested', money(result.totalInvested)),
                      StatCol('Total Gains', money(result.totalGains),
                          color: cs.tertiary),
                      StatCol('Abs. Return',
                          '${result.absoluteReturnPercent.round()}%'),
                    ]),
                  ],
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Breakdown',
            subtitle: 'Invested vs returns',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment('Invested', result.totalInvested, cs.primary),
                BreakdownSegment('Returns', result.totalGains, cs.tertiary),
              ],
              centerBig: formatter.formatCompactCurrency(result.futureValue,
                  symbol: currency.symbol),
              centerSmall: 'VALUE',
            ),
          ),
          ToolSection(
            title: 'Growth over time',
            subtitle: 'Invested vs portfolio value',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Portfolio value',
                    points: result.valueSeries,
                    color: cs.tertiary,
                    fill: true),
                ChartSeries(
                    name: 'Invested',
                    points: result.investedSeries,
                    color: cs.primary,
                    dashed: true),
              ],
              xLabels: [
                for (var i = 0; i < result.valueSeries.length; i++) 'Y$i',
              ],
            ),
          ),
          ToolSection(
            title: 'Year-by-year',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Period', numeric: false),
                ScheduleColumn('Invested'),
                ScheduleColumn('Portfolio Value'),
                ScheduleColumn('Gains'),
                ScheduleColumn('Return %'),
              ],
              toggleLabels: _isSip ? const ['Yearly', 'Monthly'] : null,
              toggleIndex: _scheduleMode,
              onToggle: (i) => setState(() => _scheduleMode = i),
              rows: (_isSip && _scheduleMode == 1)
                  ? [
                      for (final m in sipMonthlyRows(
                          parseAmount(_amountCtrl.text),
                          parseNum(_rateCtrl.text),
                          _years))
                        [
                          'M${m[0].toInt()}',
                          money(m[1]),
                          money(m[2]),
                          money(m[3]),
                          '${m[4].round()}%',
                        ],
                    ]
                  : [
                      for (var y = 1; y < result.valueSeries.length; y++)
                        [
                          'Y$y',
                          money(result.investedSeries[y]),
                          money(result.valueSeries[y]),
                          money(result.valueSeries[y] -
                              result.investedSeries[y]),
                          '${result.investedSeries[y] == 0 ? 0 : ((result.valueSeries[y] - result.investedSeries[y]) / result.investedSeries[y] * 100).round()}%',
                        ],
                    ],
            ),
          ),
        ],
      ],
    );
  }
}
