import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/emi_engine.dart';
import '../engine/monthly_schedules.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';

class EmiCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const EmiCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<EmiCalculatorScreen> createState() =>
      _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends ConsumerState<EmiCalculatorScreen>
    with CalculatorSupport {
  final _principalCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  int _tenureUnit = 0; // 0 = Years, 1 = Months
  int _scheduleMode = 0; // 0 = Yearly, 1 = Monthly

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'emi-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Home loan';
  @override
  String get savePlaceholder => 'e.g. Home loan Mumbai';

  int get _tenureMonths {
    final t = parseNum(_tenureCtrl.text);
    return (_tenureUnit == 0 ? t * 12 : t).round();
  }

  @override
  Map<String, dynamic> collectInputs() => {
        'principal': _principalCtrl.text,
        'rate': _rateCtrl.text,
        'tenure': _tenureCtrl.text,
        'tenureUnit': _tenureUnit,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _principalCtrl.text = json['principal']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '';
    _tenureUnit = json['tenureUnit'] as int? ?? 0;
  }

  EmiResult? _compute() {
    final p = parseAmount(_principalCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    final months = _tenureMonths;
    if (p <= 0 || rate <= 0 || months <= 0) return null;
    return computeEmiSchedule(p, rate, months);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final years = (_tenureMonths / 12).toStringAsFixed(0);
    final p = formatter.formatCurrency(parseAmount(_principalCtrl.text),
        symbol: currency.symbol);
    if (r == null) return '$p loan';
    return '$p @ ${_rateCtrl.text}% for ${years}y → EMI ${formatter.formatCurrency(r.emi, symbol: currency.symbol)}';
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
      title: 'EMI Calculator',
      subtitle: 'Monthly payment and total interest over the life of your loan',
      infoConfig: InfoConstants.emiCalculator,
      overflowConfig: savedOverflowConfig('EMI'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      isSavedView: hasSaved,
      isModified: isModified,
      onUpdate: updateSaved,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _principalCtrl,
            label: 'LOAN AMOUNT',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 50000,
            max: 10000000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _rateCtrl,
            label: 'ANNUAL INTEREST RATE',
            suffix: '%',
            helper: 'Annual rate, as a percentage',
            onChanged: recompute,
            min: 1,
            max: 20,
            divisions: 190,
          ),
          const SizedBox(height: KuberSpacing.lg),
          const ToolInputLabel('TENURE'),
          const SizedBox(height: KuberSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ToolTextField(
                    controller: _tenureCtrl, onChanged: recompute),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: ToolSegmentedControl(
                  labels: const ['Years', 'Months'],
                  selectedIndex: _tenureUnit,
                  onChanged: (i) => setState(() => _tenureUnit = i),
                ),
              ),
            ],
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
                      label: 'Monthly EMI',
                      value: money(result.emi),
                      color: cs.primary,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol('Total Interest', money(result.totalInterest),
                          color: cs.error),
                      StatCol('Total Payable', money(result.totalPayable)),
                      StatCol('Interest / Principal',
                          '${(result.totalInterest / result.principal * 100).round()}%'),
                    ]),
                  ],
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Breakdown',
            subtitle: 'Principal vs interest',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment('Principal', result.principal, cs.primary),
                BreakdownSegment('Interest', result.totalInterest, cs.error),
              ],
              centerBig: formatter.formatCompactCurrency(result.totalPayable,
                  symbol: currency.symbol),
              centerSmall: 'TOTAL',
            ),
          ),
          ToolSection(
            title: 'Balance over time',
            subtitle: 'Outstanding vs cumulative interest',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Outstanding balance',
                    points: result.balanceSeries,
                    color: cs.primary),
                ChartSeries(
                    name: 'Cumulative interest',
                    points: result.interestSeries,
                    color: cs.error),
              ],
              xLabels: [
                for (var i = 0; i < result.balanceSeries.length; i++) 'Y$i',
              ],
            ),
          ),
          ToolSection(
            title: 'Amortization schedule',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Period', numeric: false),
                ScheduleColumn('Opening'),
                ScheduleColumn('Total Paid'),
                ScheduleColumn('Principal'),
                ScheduleColumn('Interest'),
                ScheduleColumn('Closing'),
              ],
              toggleLabels: const ['Yearly', 'Monthly'],
              toggleIndex: _scheduleMode,
              onToggle: (i) => setState(() => _scheduleMode = i),
              note: 'Scroll horizontally for all columns.',
              rows: _scheduleMode == 0
                  ? [
                      for (final y in result.yearly)
                        [
                          'Y${y.year}',
                          money(y.opening),
                          money(y.totalPaid),
                          money(y.principal),
                          money(y.interest),
                          money(y.closing),
                        ],
                    ]
                  : [
                      for (final m in emiMonthlyRows(
                          result.principal,
                          parseNum(_rateCtrl.text),
                          _tenureMonths))
                        [
                          'M${m[0].toInt()}',
                          money(m[1]),
                          money(m[2]),
                          money(m[3]),
                          money(m[4]),
                          money(m[5]),
                        ],
                    ],
            ),
          ),
        ],
      ],
    );
  }
}
