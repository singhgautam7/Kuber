import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/investment_engine.dart';
import '../engine/monthly_schedules.dart';
import '../engine/sip_required_engine.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class SipAmountFinderScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const SipAmountFinderScreen({super.key, this.savedId});

  @override
  ConsumerState<SipAmountFinderScreen> createState() =>
      _SipAmountFinderScreenState();
}

class _SipAmountFinderScreenState extends ConsumerState<SipAmountFinderScreen>
    with CalculatorSupport {
  final _targetCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  int _scheduleMode = 0;

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _rateCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'sip-amount-finder';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Goal SIP';
  @override
  String get savePlaceholder => "e.g. Daughter's college fund";

  int get _years => parseNum(_tenureCtrl.text).round();

  @override
  Map<String, dynamic> collectInputs() => {
        'target': _targetCtrl.text,
        'rate': _rateCtrl.text,
        'tenure': _tenureCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _targetCtrl.text = json['target']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '';
  }

  SipRequiredResult? _compute() {
    final target = parseAmount(_targetCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    if (target <= 0 || rate <= 0 || _years <= 0) return null;
    return computeSipRequired(target, rate, _years);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final t = formatter.formatCurrency(parseAmount(_targetCtrl.text),
        symbol: currency.symbol);
    if (r == null) return 'Target $t';
    return '$t in ${_years}y @ ${_rateCtrl.text}% → ${formatter.formatCurrency(r.monthlyAmount, symbol: currency.symbol)}/mo';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final result = _compute();
    final target = parseAmount(_targetCtrl.text);
    final series = result == null
        ? null
        : computeSip(result.monthlyAmount, parseNum(_rateCtrl.text), _years);
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'SIP Amount',
      subtitle: 'The monthly SIP you need to reach a target',
      infoConfig: InfoConstants.sipAmountFinder,
      overflowConfig: savedOverflowConfig('SIP'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _targetCtrl,
            label: 'TARGET AMOUNT',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 100000,
            max: 50000000,
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
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToolHero(
                      label: 'Monthly SIP Required',
                      value: money(result.monthlyAmount),
                      numericValue: result.monthlyAmount,
                      format: money,
                      color: ToolAccents.purple,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol(
                          'Total Investment', money(result.totalInvestment)),
                      StatCol('Total Gains', money(result.totalGains),
                          color: cs.tertiary),
                    ]),
                  ],
                ),
        ),
        if (result != null && series != null) ...[
          ToolSection(
            title: 'Breakdown',
            subtitle: 'Investment vs gains',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment(
                    'Investment', result.totalInvestment, cs.primary),
                BreakdownSegment('Gains', result.totalGains, cs.tertiary),
              ],
              centerBig: formatter.formatCompactCurrency(target,
                  symbol: currency.symbol),
              centerSmall: 'TARGET',
            ),
          ),
          ToolSection(
            title: 'Progress to target',
            subtitle: 'Portfolio vs target',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Portfolio value',
                    points: series.valueSeries,
                    color: ToolAccents.purple,
                    fill: true),
              ],
              xLabels: [
                for (var i = 0; i < series.valueSeries.length; i++) 'Y$i',
              ],
              target: target,
              targetColor: cs.tertiary,
              targetLabel: 'Target',
            ),
          ),
          ToolSection(
            title: 'Year-by-year',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Period', numeric: false),
                ScheduleColumn('Cumulative Invested'),
                ScheduleColumn('Portfolio Value'),
                ScheduleColumn('Progress %'),
              ],
              toggleLabels: const ['Yearly', 'Monthly'],
              toggleIndex: _scheduleMode,
              onToggle: (i) => setState(() => _scheduleMode = i),
              rows: _scheduleMode == 1
                  ? [
                      for (final m in sipMonthlyRows(
                          result.monthlyAmount, parseNum(_rateCtrl.text), _years))
                        [
                          'M${m[0].toInt()}',
                          money(m[1]),
                          money(m[2]),
                          '${target == 0 ? 0 : (m[2] / target * 100).clamp(0, 100).round()}%',
                        ],
                    ]
                  : [
                      for (var y = 1; y < series.valueSeries.length; y++)
                        [
                          'Y$y',
                          money(series.investedSeries[y]),
                          money(series.valueSeries[y]),
                          '${target == 0 ? 0 : (series.valueSeries[y] / target * 100).clamp(0, 100).round()}%',
                        ],
                    ],
            ),
          ),
        ],
      ],
    );
  }
}
