import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/retirement_engine.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class RetirementCorpusScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const RetirementCorpusScreen({super.key, this.savedId});

  @override
  ConsumerState<RetirementCorpusScreen> createState() =>
      _RetirementCorpusScreenState();
}

class _RetirementCorpusScreenState extends ConsumerState<RetirementCorpusScreen>
    with CalculatorSupport {
  final _ageCtrl = TextEditingController();
  final _retireCtrl = TextEditingController();
  final _lifeCtrl = TextEditingController();
  final _expenseCtrl = TextEditingController();
  final _inflationCtrl = TextEditingController();
  final _preCtrl = TextEditingController();
  final _postCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    for (final c in [
      _ageCtrl,
      _retireCtrl,
      _lifeCtrl,
      _expenseCtrl,
      _inflationCtrl,
      _preCtrl,
      _postCtrl,
      _savingsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  String get toolKey => 'retirement-corpus';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Retirement plan';
  @override
  String get savePlaceholder => 'e.g. My retirement';

  @override
  Map<String, dynamic> collectInputs() => {
        'age': _ageCtrl.text,
        'retire': _retireCtrl.text,
        'life': _lifeCtrl.text,
        'expense': _expenseCtrl.text,
        'inflation': _inflationCtrl.text,
        'pre': _preCtrl.text,
        'post': _postCtrl.text,
        'savings': _savingsCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _ageCtrl.text = json['age']?.toString() ?? '';
    _retireCtrl.text = json['retire']?.toString() ?? '';
    _lifeCtrl.text = json['life']?.toString() ?? '';
    _expenseCtrl.text = json['expense']?.toString() ?? '';
    _inflationCtrl.text = json['inflation']?.toString() ?? '';
    _preCtrl.text = json['pre']?.toString() ?? '';
    _postCtrl.text = json['post']?.toString() ?? '';
    _savingsCtrl.text = json['savings']?.toString() ?? '';
  }

  int get _age => parseNum(_ageCtrl.text).round();
  int get _retire => parseNum(_retireCtrl.text).round();
  int get _life => parseNum(_lifeCtrl.text).round();

  String? get _validationError {
    if (_age <= 0 || _retire <= 0 || _life <= 0) return null;
    if (_retire <= _age) return 'Retirement age must be greater than current age.';
    if (_life <= _retire) {
      return 'Life expectancy must be greater than retirement age.';
    }
    return null;
  }

  RetirementResult? _compute() {
    final expense = parseAmount(_expenseCtrl.text);
    final inflation = parseNum(_inflationCtrl.text);
    final pre = parseNum(_preCtrl.text);
    final post = parseNum(_postCtrl.text);
    if (_age <= 0 || _retire <= _age || _life <= _retire) return null;
    if (expense <= 0 || inflation <= 0 || pre <= 0 || post <= 0) return null;
    return computeRetirement(
      currentAge: _age,
      retirementAge: _retire,
      lifeExpectancy: _life,
      currentMonthlyExpense: expense,
      inflationPercent: inflation,
      preRetirementReturnPercent: pre,
      postRetirementReturnPercent: post,
      currentSavings: parseAmount(_savingsCtrl.text),
    );
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    if (r == null) return 'Retirement plan';
    return 'Corpus ${formatter.formatCompactCurrency(r.requiredCorpus, symbol: currency.symbol)} → ${formatter.formatCurrency(r.monthlyInvestment, symbol: currency.symbol)}/mo';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    String compact(double v) =>
        formatter.formatCompactCurrency(v, symbol: currency.symbol);
    final result = _compute();
    final error = _validationError;
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'Retirement Corpus',
      subtitle: 'The corpus you need and how to build it',
      infoConfig: InfoConstants.retirementCorpus,
      overflowConfig: savedOverflowConfig('retirement'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          Row(
            children: [
              Expanded(
                  child: ToolTextField(
                      controller: _ageCtrl,
                      label: 'CURRENT AGE',
                      onChanged: recompute)),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                  child: ToolTextField(
                      controller: _retireCtrl,
                      label: 'RETIRE AT',
                      onChanged: recompute)),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                  child: ToolTextField(
                      controller: _lifeCtrl,
                      label: 'LIVE TILL',
                      onChanged: recompute)),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error,
                  style: localeFont(fontSize: 11.5, color: cs.error)),
            ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _expenseCtrl,
            label: 'CURRENT MONTHLY EXPENSE',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 10000,
            max: 500000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _inflationCtrl,
            label: 'INFLATION RATE',
            suffix: '%',
            onChanged: recompute,
            min: 1,
            max: 12,
            divisions: 110,
          ),
          const SizedBox(height: KuberSpacing.lg),
          Row(
            children: [
              Expanded(
                  child: ToolTextField(
                      controller: _preCtrl,
                      label: 'PRE-RET. RETURN',
                      suffix: '%',
                      onChanged: recompute)),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                  child: ToolTextField(
                      controller: _postCtrl,
                      label: 'POST-RET. RETURN',
                      suffix: '%',
                      onChanged: recompute)),
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _savingsCtrl,
            label: 'CURRENT SAVINGS',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 0,
            max: 50000000,
          ),
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : ToolDualHero(
                  left: HeroSide(
                    label: 'Required Corpus',
                    value: compact(result.requiredCorpus),
                    color: ToolAccents.emerald,
                    sub: 'at age $_retire',
                  ),
                  right: HeroSide(
                    label: 'Monthly Investment',
                    value: money(result.monthlyInvestment),
                    color: cs.primary,
                    sub: 'for the next ${result.yearsToRetirement} years',
                  ),
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Secondary',
            child: ToolStatCols(items: [
              StatCol('Yrs to Retire', '${result.yearsToRetirement}'),
              StatCol('Yrs in Retire', '${result.yearsInRetirement}'),
              StatCol('Expense @retire /mo',
                  compact(result.monthlyExpenseAtRetirement)),
              StatCol('Total Invested', compact(result.totalInvested)),
            ]),
          ),
          ToolSection(
            title: 'Breakdown',
            subtitle: 'What builds your corpus',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment('Current savings (grown)',
                    result.fvCurrentSavings, cs.primary),
                BreakdownSegment('Future investments', result.totalInvested,
                    ToolAccents.amber),
                BreakdownSegment('Returns', result.returns, cs.tertiary),
              ],
              centerBig: compact(result.requiredCorpus),
              centerSmall: 'CORPUS',
            ),
          ),
          ToolSection(
            title: 'Phase 1 — Corpus growth',
            subtitle: 'Working years (age $_age → $_retire)',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Corpus',
                    points: result.preRetirementSeries,
                    color: ToolAccents.emerald,
                    fill: true),
              ],
              xLabels: [
                for (var i = 0; i < result.preRetirementSeries.length; i++)
                  '${_age + i}',
              ],
            ),
          ),
          ToolSection(
            title: 'Phase 2 — Corpus drawdown',
            subtitle: 'Retirement years (age $_retire → $_life)',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Remaining corpus',
                    points: result.postRetirementSeries,
                    color: ToolAccents.amber,
                    fill: true),
              ],
              xLabels: [
                for (var i = 0; i < result.postRetirementSeries.length; i++)
                  '${_retire + i}',
              ],
            ),
          ),
          ToolSection(
            title: 'Schedule',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PhaseHeader('Phase 1 — Working years', ToolAccents.emerald),
                const SizedBox(height: KuberSpacing.sm),
                ToolScheduleTable(
                  columns: const [
                    ScheduleColumn('Age', numeric: false),
                    ScheduleColumn('Investment'),
                    ScheduleColumn('Corpus Value'),
                  ],
                  rows: [
                    for (final p in result.phase1)
                      ['${p.age}', money(p.investment), money(p.corpusValue)],
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                _PhaseHeader('Phase 2 — Retirement years', ToolAccents.amber),
                const SizedBox(height: KuberSpacing.sm),
                ToolScheduleTable(
                  dataColumnWidth: 124,
                  columns: const [
                    ScheduleColumn('Age', numeric: false),
                    ScheduleColumn('Monthly Expense'),
                    ScheduleColumn('Withdrawal'),
                    ScheduleColumn('Remaining Corpus'),
                  ],
                  rows: [
                    for (final p in result.phase2)
                      [
                        '${p.age}',
                        money(p.annualExpense / 12),
                        money(p.withdrawal),
                        money(p.remainingCorpus),
                      ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _PhaseHeader(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: localeFont(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.6,
      ),
    );
  }
}
