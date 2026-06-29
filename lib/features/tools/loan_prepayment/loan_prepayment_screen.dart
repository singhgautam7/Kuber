import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/loan_prepayment_engine.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';

class LoanPrepaymentScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const LoanPrepaymentScreen({super.key, this.savedId});

  @override
  ConsumerState<LoanPrepaymentScreen> createState() =>
      _LoanPrepaymentScreenState();
}

class _LoanPrepaymentScreenState extends ConsumerState<LoanPrepaymentScreen>
    with CalculatorSupport {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  final _prepayCtrl = TextEditingController();
  final _startYearCtrl = TextEditingController(text: '1');
  int _type = 1; // 0 = One-time, 1 = Yearly
  int _scenario = 1; // 0 = Without, 1 = With

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
    _prepayCtrl.dispose();
    _startYearCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'loan-prepayment';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Loan prepayment';
  @override
  String get savePlaceholder => 'e.g. Car loan prepay';

  int get _years => parseNum(_tenureCtrl.text).round();

  @override
  Map<String, dynamic> collectInputs() => {
        'amount': _amountCtrl.text,
        'rate': _rateCtrl.text,
        'tenure': _tenureCtrl.text,
        'prepay': _prepayCtrl.text,
        'startYear': _startYearCtrl.text,
        'type': _type,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _amountCtrl.text = json['amount']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '';
    _prepayCtrl.text = json['prepay']?.toString() ?? '';
    _startYearCtrl.text = json['startYear']?.toString() ?? '1';
    _type = json['type'] as int? ?? 1;
  }

  PrepaymentResult? _compute() {
    final amount = parseAmount(_amountCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    final prepay = parseAmount(_prepayCtrl.text);
    final startYear = parseNum(_startYearCtrl.text).round().clamp(1, 100);
    if (amount <= 0 || rate <= 0 || _years <= 0 || prepay <= 0) return null;
    return computePrepayment(
      amount,
      rate,
      _years,
      type: _type == 0 ? PrepaymentType.oneTime : PrepaymentType.yearly,
      prepayAmount: prepay,
      startYear: startYear,
    );
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final pre = formatter.formatCurrency(parseAmount(_prepayCtrl.text),
        symbol: currency.symbol);
    if (r == null) return 'Prepay $pre';
    return '$pre ${_type == 0 ? 'one-time' : 'yearly'} → saves ${r.yearsSaved}y ${r.remainderMonthsSaved}m & ${formatter.formatCurrency(r.interestSaved, symbol: currency.symbol)}';
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
    final scenario = result == null
        ? null
        : (_scenario == 0 ? result.baseline : result.withPrepay);

    return ToolScreenScaffold(
      title: 'Loan Prepayment Impact',
      subtitle: 'The tenure and interest you could save',
      infoConfig: InfoConstants.loanPrepayment,
      overflowConfig: savedOverflowConfig('prepayment'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _amountCtrl,
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
            label: 'INTEREST RATE',
            suffix: '%',
            onChanged: recompute,
            min: 1,
            max: 20,
            divisions: 190,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _tenureCtrl,
            label: 'ORIGINAL TENURE',
            suffix: 'years',
            onChanged: recompute,
          ),
          const SizedBox(height: KuberSpacing.lg),
          const ToolInputLabel('PREPAYMENT TYPE'),
          const SizedBox(height: KuberSpacing.sm),
          ToolSegmentedControl(
            labels: const ['One-time', 'Yearly'],
            selectedIndex: _type,
            onChanged: (i) => setState(() => _type = i),
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _prepayCtrl,
            label: 'PREPAYMENT AMOUNT',
            prefix: currency.symbol,
            helper: _type == 0 ? 'Paid once' : 'Extra paid each year',
            formatAsAmount: true,
            onChanged: recompute,
            min: 10000,
            max: 2000000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _startYearCtrl,
            label: 'START FROM YEAR',
            suffix: 'year',
            onChanged: recompute,
          ),
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : ToolDualHero(
                  left: HeroSide(
                    label: 'Tenure Saved',
                    value:
                        '${result.yearsSaved}y ${result.remainderMonthsSaved}m',
                    color: cs.primary,
                  ),
                  right: HeroSide(
                    label: 'Interest Saved',
                    value: money(result.interestSaved),
                    color: cs.tertiary,
                  ),
                  bannerText: result.monthsSaved > 0
                      ? 'Loan closes ${result.yearsSaved} years ${result.remainderMonthsSaved} months early'
                      : 'No tenure saved with these inputs',
                  bannerIsPositive: result.monthsSaved > 0,
                ),
        ),
        if (result != null && scenario != null) ...[
          ToolSection(
            title: 'Breakdown',
            subtitle: 'Interest saved vs still owed',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment(
                    'Interest saved', result.interestSaved, cs.tertiary),
                BreakdownSegment('Interest still owed',
                    result.withPrepay.totalInterest, cs.error),
              ],
              centerBig: formatter.formatCompactCurrency(
                  result.baseline.totalInterest,
                  symbol: currency.symbol),
              centerSmall: 'ORIGINAL',
            ),
          ),
          ToolSection(
            title: 'Balance comparison',
            subtitle: 'With vs without prepayment',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Without prepayment',
                    points: result.baseline.balanceSeries,
                    color: cs.error,
                    dashed: true),
                ChartSeries(
                    name: 'With prepayment',
                    points: result.withPrepay.balanceSeries,
                    color: cs.tertiary),
              ],
              xLabels: [
                for (var i = 0; i < result.baseline.balanceSeries.length; i++)
                  'Y$i',
              ],
            ),
          ),
          ToolSection(
            title: 'Schedule',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Year', numeric: false),
                ScheduleColumn('EMI Paid'),
                ScheduleColumn('Prepayment'),
                ScheduleColumn('Principal'),
                ScheduleColumn('Interest'),
                ScheduleColumn('Balance'),
              ],
              toggleLabels: const ['Without', 'With'],
              toggleIndex: _scenario,
              onToggle: (i) => setState(() => _scenario = i),
              note: 'Toggle scenarios: without / with prepayment.',
              rows: [
                for (final y in scenario.yearly)
                  [
                    'Y${y.year}',
                    money(y.emiPaid),
                    money(y.prepayment),
                    money(y.principal),
                    money(y.interest),
                    money(y.closing),
                  ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
