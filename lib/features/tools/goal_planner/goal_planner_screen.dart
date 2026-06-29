import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/goal_planner_engine.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class GoalPlannerScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const GoalPlannerScreen({super.key, this.savedId});

  @override
  ConsumerState<GoalPlannerScreen> createState() => _GoalPlannerScreenState();
}

class _GoalPlannerScreenState extends ConsumerState<GoalPlannerScreen>
    with CalculatorSupport {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  int _scheduleMode = 0;

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _yearsCtrl.dispose();
    _rateCtrl.dispose();
    _savingsCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'goal-planner';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName =>
      _nameCtrl.text.trim().isEmpty ? 'Financial goal' : _nameCtrl.text.trim();
  @override
  String get savePlaceholder => "e.g. Daughter's college fund";

  int get _years => parseNum(_yearsCtrl.text).round();

  @override
  Map<String, dynamic> collectInputs() => {
        'name': _nameCtrl.text,
        'target': _targetCtrl.text,
        'years': _yearsCtrl.text,
        'rate': _rateCtrl.text,
        'savings': _savingsCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _nameCtrl.text = json['name']?.toString() ?? '';
    _targetCtrl.text = json['target']?.toString() ?? '';
    _yearsCtrl.text = json['years']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _savingsCtrl.text = json['savings']?.toString() ?? '';
  }

  GoalResult? _compute() {
    final target = parseAmount(_targetCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    if (target <= 0 || rate <= 0 || _years <= 0) return null;
    return computeGoal(
      target: target,
      years: _years,
      ratePercent: rate,
      currentSavings: parseAmount(_savingsCtrl.text),
    );
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final t = formatter.formatCurrency(parseAmount(_targetCtrl.text),
        symbol: currency.symbol);
    if (r == null) return 'Goal $t';
    return '$t in ${_years}y → ${formatter.formatCurrency(r.monthlyInvestment, symbol: currency.symbol)}/mo';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final result = _compute();
    final savings = parseAmount(_savingsCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'Goal Planner',
      subtitle: 'The monthly investment to reach your goal',
      infoConfig: InfoConstants.goalPlanner,
      overflowConfig: savedOverflowConfig('goal'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          const ToolInputLabel('GOAL NAME'),
          const SizedBox(height: KuberSpacing.sm),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            onChanged: recompute,
            style: localeFont(
                fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'e.g. Down payment',
              hintStyle: localeFont(fontSize: 15, color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.md, vertical: KuberSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.primary),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
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
            controller: _yearsCtrl,
            label: 'YEARS TO GOAL',
            suffix: 'years',
            onChanged: recompute,
            min: 1,
            max: 40,
            divisions: 39,
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
            controller: _savingsCtrl,
            label: 'CURRENT SAVINGS',
            prefix: currency.symbol,
            helper: 'Optional — defaults to ₹0',
            formatAsAmount: true,
            onChanged: recompute,
            min: 0,
            max: 10000000,
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
                      label: 'Monthly Investment Needed',
                      value: money(result.monthlyInvestment),
                      numericValue: result.monthlyInvestment,
                      format: money,
                      color: ToolAccents.amber,
                    ),
                    if (result.alreadyOnTrack)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Already on track — ₹0/mo needed',
                          style: localeFont(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: cs.tertiary),
                        ),
                      ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol('Total Investment', money(result.totalInvestment)),
                      StatCol('Returns', money(result.returns),
                          color: cs.tertiary),
                      StatCol('Final Corpus', money(result.finalCorpus)),
                    ]),
                  ],
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Breakdown',
            subtitle: 'What makes up your corpus',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment('Current savings', savings, cs.primary),
                BreakdownSegment(
                    'Investment', result.totalInvestment, ToolAccents.amber),
                BreakdownSegment('Returns', result.returns, cs.tertiary),
              ],
              centerBig: formatter.formatCompactCurrency(result.finalCorpus,
                  symbol: currency.symbol),
              centerSmall: 'CORPUS',
            ),
          ),
          ToolSection(
            title: 'Progress to goal',
            subtitle: 'Portfolio vs target',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Portfolio value',
                    points: result.valueSeries,
                    color: ToolAccents.amber,
                    fill: true),
              ],
              xLabels: [
                for (var i = 0; i < result.valueSeries.length; i++) 'Y$i',
              ],
              target: result.target,
              targetColor: cs.primary,
              targetLabel: 'Target',
            ),
          ),
          ToolSection(
            title: 'Year-by-year',
            child: ToolScheduleTable(
              dataColumnWidth: 116,
              columns: const [
                ScheduleColumn('Year', numeric: false),
                ScheduleColumn('Monthly Inv.'),
                ScheduleColumn('Total Invested'),
                ScheduleColumn('Returns'),
                ScheduleColumn('Total Value'),
                ScheduleColumn('Progress %'),
              ],
              toggleLabels: const ['Yearly', 'Monthly'],
              toggleIndex: _scheduleMode,
              onToggle: (i) => setState(() => _scheduleMode = i),
              rows: _scheduleMode == 1
                  ? _monthlyRows(result, savings, rate, money)
                  : [
                      for (final y in result.yearly)
                        [
                          'Y${y.year}',
                          money(result.monthlyInvestment),
                          money(y.totalInvested),
                          money(y.returns),
                          money(y.totalValue),
                          '${y.progressPercent.round()}%',
                        ],
                    ],
            ),
          ),
        ],
      ],
    );
  }

  List<List<String>> _monthlyRows(
      GoalResult result, double savings, double rate, String Function(double) money) {
    final r = rate / 100 / 12;
    final monthly = result.monthlyInvestment;
    final rows = <List<String>>[];
    double v = savings;
    for (var m = 1; m <= _years * 12; m++) {
      v = v * (1 + r) + monthly;
      final invested = monthly * m;
      rows.add([
        'M$m',
        money(monthly),
        money(invested),
        money((v - savings - invested).clamp(0, double.infinity)),
        money(v),
        '${result.target == 0 ? 0 : (v / result.target * 100).clamp(0, 100).round()}%',
      ]);
    }
    return rows;
  }
}
