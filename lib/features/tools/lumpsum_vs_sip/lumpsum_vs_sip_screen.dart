import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/lumpsum_vs_sip_engine.dart';
import '../engine/monthly_schedules.dart';
import '../widgets/calculator_bar_compare.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class LumpsumVsSipScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const LumpsumVsSipScreen({super.key, this.savedId});

  @override
  ConsumerState<LumpsumVsSipScreen> createState() => _LumpsumVsSipScreenState();
}

class _LumpsumVsSipScreenState extends ConsumerState<LumpsumVsSipScreen>
    with CalculatorSupport {
  final _totalCtrl = TextEditingController();
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
    _totalCtrl.dispose();
    _rateCtrl.dispose();
    _tenureCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'lumpsum-vs-sip';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Lumpsum vs SIP';
  @override
  String get savePlaceholder => 'e.g. Bonus investment';

  int get _years => parseNum(_tenureCtrl.text).round();

  @override
  Map<String, dynamic> collectInputs() => {
        'total': _totalCtrl.text,
        'rate': _rateCtrl.text,
        'tenure': _tenureCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _totalCtrl.text = json['total']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '';
  }

  LumpsumVsSipResult? _compute() {
    final total = parseAmount(_totalCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    if (total <= 0 || rate <= 0 || _years <= 0) return null;
    return computeLumpsumVsSip(total, rate, _years);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final t = formatter.formatCurrency(parseAmount(_totalCtrl.text),
        symbol: currency.symbol);
    if (r == null) return 'Lumpsum vs SIP $t';
    final winner = r.lumpsumWins ? 'Lumpsum' : 'SIP';
    return '$t @ ${_rateCtrl.text}% / ${_years}y → $winner wins (+${r.differencePercent.round()}%)';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final result = _compute();
    final total = parseAmount(_totalCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'Lumpsum vs SIP',
      subtitle: 'Which way of investing the same money wins',
      infoConfig: InfoConstants.lumpsumVsSip,
      overflowConfig: savedOverflowConfig('comparison'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _totalCtrl,
            label: 'TOTAL INVESTMENT',
            prefix: currency.symbol,
            helper: 'Invested upfront, or spread monthly',
            formatAsAmount: true,
            onChanged: recompute,
            min: 50000,
            max: 10000000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _rateCtrl,
            label: 'EXPECTED RETURN',
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
                    ToolDualHero(
                      left: HeroSide(
                        label: 'Lumpsum Final Value',
                        value: money(result.lumpsum.futureValue),
                        color: ToolAccents.emerald,
                      ),
                      right: HeroSide(
                        label: 'SIP Final Value',
                        value: money(result.sip.futureValue),
                        color: cs.primary,
                      ),
                      bannerText:
                          'Winner: ${result.lumpsumWins ? 'Lumpsum' : 'SIP'} — ahead by ${money(result.difference.abs())} (${result.differencePercent.round()}%)',
                      bannerIsPositive: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol('Difference', money(result.difference.abs())),
                      StatCol(
                          'Difference %', '${result.differencePercent.round()}%'),
                    ]),
                  ],
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Side-by-side',
            child: ToolBarCompare(
              categories: const ['Lumpsum', 'SIP'],
              series: [
                BarCompareSeries(
                  name: 'Final value',
                  color: ToolAccents.emerald,
                  values: [
                    result.lumpsum.futureValue,
                    result.sip.futureValue
                  ],
                ),
                BarCompareSeries(
                  name: 'Invested',
                  color: cs.onSurfaceVariant,
                  values: [
                    result.lumpsum.totalInvested,
                    result.sip.totalInvested
                  ],
                ),
              ],
            ),
          ),
          ToolSection(
            title: 'Trajectory over time',
            subtitle: 'Lumpsum vs SIP portfolio value',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Lumpsum',
                    points: result.lumpsum.valueSeries,
                    color: ToolAccents.emerald),
                ChartSeries(
                    name: 'SIP',
                    points: result.sip.valueSeries,
                    color: cs.primary),
              ],
              xLabels: [
                for (var i = 0; i < result.lumpsum.valueSeries.length; i++)
                  'Y$i',
              ],
            ),
          ),
          ToolSection(
            title: 'Year-by-year',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Period', numeric: false),
                ScheduleColumn('Lumpsum Value'),
                ScheduleColumn('SIP Invested'),
                ScheduleColumn('SIP Value'),
                ScheduleColumn('Difference'),
              ],
              toggleLabels: const ['Yearly', 'Monthly'],
              toggleIndex: _scheduleMode,
              onToggle: (i) => setState(() => _scheduleMode = i),
              rows: _scheduleMode == 1
                  ? [
                      for (final m in sipMonthlyRows(
                          result.monthlySip, rate, _years))
                        [
                          'M${m[0].toInt()}',
                          money(total * pow(1 + rate / 100, m[0] / 12)),
                          money(m[1]),
                          money(m[2]),
                          money(total * pow(1 + rate / 100, m[0] / 12) - m[2]),
                        ],
                    ]
                  : [
                      for (var y = 1; y < result.lumpsum.valueSeries.length; y++)
                        [
                          'Y$y',
                          money(result.lumpsum.valueSeries[y]),
                          money(result.sip.investedSeries[y]),
                          money(result.sip.valueSeries[y]),
                          money(result.lumpsum.valueSeries[y] -
                              result.sip.valueSeries[y]),
                        ],
                    ],
            ),
          ),
        ],
      ],
    );
  }
}
