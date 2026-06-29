import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/fd_rd_engine.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_line_chart.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class FdRdCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const FdRdCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<FdRdCalculatorScreen> createState() =>
      _FdRdCalculatorScreenState();
}

class _FdRdCalculatorScreenState extends ConsumerState<FdRdCalculatorScreen>
    with CalculatorSupport {
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  int _type = 0; // 0 = FD, 1 = RD
  int _freq = 2; // 0 yearly, 1 half-yearly, 2 quarterly, 3 monthly
  int _scheduleMode = 0;

  static const _freqs = [
    CompoundingFrequency.yearly,
    CompoundingFrequency.halfYearly,
    CompoundingFrequency.quarterly,
    CompoundingFrequency.monthly,
  ];

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
  String get toolKey => 'fd-rd-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => _type == 0 ? 'Fixed deposit' : 'Recurring deposit';
  @override
  String get savePlaceholder => 'e.g. Emergency FD';

  bool get _isFd => _type == 0;
  int get _years => parseNum(_tenureCtrl.text).round();

  @override
  Map<String, dynamic> collectInputs() => {
        'amount': _amountCtrl.text,
        'rate': _rateCtrl.text,
        'tenure': _tenureCtrl.text,
        'type': _type,
        'freq': _freq,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _amountCtrl.text = json['amount']?.toString() ?? '';
    _rateCtrl.text = json['rate']?.toString() ?? '';
    _tenureCtrl.text = json['tenure']?.toString() ?? '';
    _type = json['type'] as int? ?? 0;
    _freq = json['freq'] as int? ?? 2;
  }

  DepositResult? _compute() {
    final amount = parseAmount(_amountCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    if (amount <= 0 || rate <= 0 || _years <= 0) return null;
    return _isFd
        ? computeFd(amount, rate, _years, _freqs[_freq])
        : computeRd(amount, rate, _years);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    final amt = formatter.formatCurrency(parseAmount(_amountCtrl.text),
        symbol: currency.symbol);
    final kind = _isFd ? 'FD' : 'RD';
    if (r == null) return '$kind $amt';
    return '$kind $amt @ ${_rateCtrl.text}% for ${_years}y → ${formatter.formatCurrency(r.maturity, symbol: currency.symbol)}';
  }

  // Monthly schedule rows: [opening, interest, closing] per month.
  List<List<double>> _monthlyRows() {
    final amount = parseAmount(_amountCtrl.text);
    final rate = parseNum(_rateCtrl.text);
    final months = _years * 12;
    final rows = <List<double>>[];
    if (_isFd) {
      final f = _freqs[_freq].perYear;
      final pr = rate / 100 / f;
      double prev = amount;
      for (var m = 1; m <= months; m++) {
        final bal = amount * pow(1 + pr, f * m / 12);
        rows.add([m.toDouble(), prev, bal - prev, bal]);
        prev = bal.toDouble();
      }
    } else {
      final r = rate / 100 / 12;
      double bal = 0;
      for (var m = 1; m <= months; m++) {
        final opening = bal;
        bal = (bal + amount) * (1 + r);
        rows.add([m.toDouble(), opening, bal - opening - amount, bal]);
      }
    }
    return rows;
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
      title: 'FD / RD',
      subtitle: 'Maturity value of a fixed or recurring deposit',
      infoConfig: InfoConstants.fdRdCalculator,
      overflowConfig: savedOverflowConfig('FD/RD'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          const ToolInputLabel('DEPOSIT TYPE'),
          const SizedBox(height: KuberSpacing.sm),
          ToolSegmentedControl(
            labels: const ['Fixed (FD)', 'Recurring (RD)'],
            selectedIndex: _type,
            onChanged: (i) => setState(() => _type = i),
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _amountCtrl,
            label: _isFd ? 'PRINCIPAL AMOUNT' : 'MONTHLY DEPOSIT',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: _isFd ? 10000 : 500,
            max: _isFd ? 10000000 : 100000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _rateCtrl,
            label: 'INTEREST RATE',
            suffix: '%',
            onChanged: recompute,
            min: 1,
            max: 12,
            divisions: 110,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _tenureCtrl,
            label: 'TENURE',
            suffix: 'years',
            onChanged: recompute,
            min: 1,
            max: 20,
            divisions: 19,
          ),
          if (_isFd) ...[
            const SizedBox(height: KuberSpacing.lg),
            const ToolInputLabel('COMPOUNDING FREQUENCY'),
            const SizedBox(height: KuberSpacing.sm),
            Wrap(
              spacing: KuberSpacing.sm,
              runSpacing: KuberSpacing.sm,
              children: [
                for (var i = 0; i < 4; i++)
                  _Chip(
                    label: const [
                      'Yearly',
                      'Half-yearly',
                      'Quarterly',
                      'Monthly'
                    ][i],
                    selected: _freq == i,
                    onTap: () => setState(() => _freq = i),
                  ),
              ],
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
                    ToolHero(
                      label: 'Maturity Amount',
                      value: money(result.maturity),
                      numericValue: result.maturity,
                      format: money,
                      color: ToolAccents.amber,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    ToolStatCols(items: [
                      StatCol('Total Invested', money(result.totalInvested)),
                      StatCol('Interest Earned', money(result.interestEarned),
                          color: cs.tertiary),
                      StatCol('Eff. Yield',
                          '${result.effectiveYieldPercent.toStringAsFixed(2)}%'),
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
                BreakdownSegment(
                    'Principal', result.totalInvested, cs.primary),
                BreakdownSegment(
                    'Interest', result.interestEarned, ToolAccents.amber),
              ],
              centerBig: formatter.formatCompactCurrency(result.maturity,
                  symbol: currency.symbol),
              centerSmall: 'MATURITY',
            ),
          ),
          ToolSection(
            title: 'Balance over time',
            child: ToolLineChart(
              series: [
                ChartSeries(
                    name: 'Balance',
                    points: result.balanceSeries,
                    color: ToolAccents.amber,
                    fill: true),
              ],
              xLabels: [
                for (var i = 0; i < result.balanceSeries.length; i++) 'Y$i',
              ],
            ),
          ),
          ToolSection(
            title: 'Period-by-period',
            child: ToolScheduleTable(
              columns: const [
                ScheduleColumn('Period', numeric: false),
                ScheduleColumn('Opening'),
                ScheduleColumn('Interest'),
                ScheduleColumn('Closing'),
              ],
              toggleLabels: const ['Yearly', 'Monthly'],
              toggleIndex: _scheduleMode,
              onToggle: (i) => setState(() => _scheduleMode = i),
              note: _isFd ? null : 'For RD, contributions are added monthly.',
              rows: _scheduleMode == 1
                  ? [
                      for (final m in _monthlyRows())
                        [
                          'M${m[0].toInt()}',
                          money(m[1]),
                          money(m[2]),
                          money(m[3]),
                        ],
                    ]
                  : [
                      for (final p in result.yearly)
                        [
                          'Y${p.period}',
                          money(p.opening),
                          money(p.interest),
                          money(p.closing),
                        ],
                    ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
