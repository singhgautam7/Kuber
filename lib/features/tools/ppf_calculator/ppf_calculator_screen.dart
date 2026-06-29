import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/ppf_engine.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class PpfCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const PpfCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<PpfCalculatorScreen> createState() =>
      _PpfCalculatorScreenState();
}

class _PpfCalculatorScreenState extends ConsumerState<PpfCalculatorScreen>
    with CalculatorSupport {
  final _depositCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController(text: '15');
  final _rateCtrl = TextEditingController(text: '7.1');

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _depositCtrl.dispose();
    _tenureCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'ppf-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'PPF account';
  @override
  String get savePlaceholder => 'e.g. PPF 15-year plan';

  int get _years => parseNum(_tenureCtrl.text).round();
  double get _rawDeposit => parseAmount(_depositCtrl.text);

  @override
  Map<String, dynamic> collectInputs() => {
        'deposit': _depositCtrl.text,
        'tenure': _tenureCtrl.text,
        'rate': _rateCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _depositCtrl.text = json['deposit']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '15';
    _rateCtrl.text = json['rate']?.toString() ?? '7.1';
  }

  PpfResult? _compute() {
    final deposit = clampPpfDeposit(_rawDeposit);
    final rate = parseNum(_rateCtrl.text);
    if (deposit <= 0 || _years <= 0 || rate <= 0) return null;
    return computePpf(deposit, _years, ratePercent: rate);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final dep = formatter.formatCurrency(clampPpfDeposit(_rawDeposit),
        symbol: currency.symbol);
    if (r == null) return 'PPF $dep/yr';
    return '$dep/yr × ${_years}y → ${formatter.formatCurrency(r.maturity, symbol: currency.symbol)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final result = _compute();
    final outOfRange = _rawDeposit > 0 &&
        (_rawDeposit < kPpfMinDeposit || _rawDeposit > kPpfMaxDeposit);
    void recompute(_) => scheduleRecompute();

    return ToolScreenScaffold(
      title: 'PPF Calculator',
      subtitle: 'Tax-free maturity built over 15 years',
      infoConfig: InfoConstants.ppfCalculator,
      overflowConfig: savedOverflowConfig('PPF'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      isSavedView: hasSaved,
      isModified: isModified,
      onUpdate: updateSaved,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _depositCtrl,
            label: 'YEARLY DEPOSIT',
            prefix: currency.symbol,
            helper: '₹500 – ₹1,50,000 per year',
            formatAsAmount: true,
            onChanged: recompute,
            min: kPpfMinDeposit,
            max: kPpfMaxDeposit,
          ),
          if (outOfRange)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Deposit clamped to the ₹500 – ₹1,50,000 limit.',
                style: localeFont(fontSize: 11.5, color: cs.error),
              ),
            ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _tenureCtrl,
            label: 'TENURE',
            suffix: 'years',
            onChanged: recompute,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text('Extendable in 5-year blocks',
                style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)),
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _rateCtrl,
            label: 'INTEREST RATE',
            suffix: '%',
            onChanged: recompute,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
                'Current PPF rate is 7.1% (subject to govt revision)',
                style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)),
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
                      label: 'Maturity Amount',
                      value: money(result.maturity),
                      color: ToolAccents.emerald,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol('Total Deposited', money(result.totalDeposited)),
                      StatCol('Interest Earned', money(result.interestEarned),
                          color: cs.tertiary),
                      const StatCol('Returns', 'Tax-free'),
                    ]),
                  ],
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Breakdown',
            subtitle: 'Deposited vs interest',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment(
                    'Deposited', result.totalDeposited, cs.primary),
                BreakdownSegment(
                    'Interest', result.interestEarned, ToolAccents.emerald),
              ],
              centerBig: formatter.formatCompactCurrency(result.maturity,
                  symbol: currency.symbol),
              centerSmall: 'MATURITY',
            ),
          ),
          ToolSection(
            title: 'PPF balance over years',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'PPF balance',
                    points: result.balanceSeries,
                    color: ToolAccents.emerald,
                    fill: true),
              ],
              xLabels: [
                for (var i = 0; i < result.balanceSeries.length; i++) 'Y$i',
              ],
            ),
          ),
          ToolSection(
            title: 'Year-by-year',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Year', numeric: false),
                ScheduleColumn('Opening'),
                ScheduleColumn('Deposit'),
                ScheduleColumn('Interest'),
                ScheduleColumn('Closing'),
              ],
              note: 'Interest credited at year-end on the closing balance.',
              rows: [
                for (final y in result.yearly)
                  [
                    'Y${y.year}',
                    money(y.opening),
                    money(y.deposit),
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
