import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/salary_engine.dart';
import '../widgets/calculator_bar_compare.dart';
import '../widgets/calculator_donut_breakdown.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_schedule_table.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';
import '../widgets/tool_accents.dart';

class SalaryCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const SalaryCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<SalaryCalculatorScreen> createState() =>
      _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends ConsumerState<SalaryCalculatorScreen>
    with CalculatorSupport {
  final _ctcCtrl = TextEditingController();
  final _basicCtrl = TextEditingController(text: '40');
  final _hraExemptCtrl = TextEditingController();
  final _c80cCtrl = TextEditingController();
  final _c80dCtrl = TextEditingController();
  final _homeLoanCtrl = TextEditingController();
  final _npsCtrl = TextEditingController();
  bool _showComponents = false;
  bool _showDeductions = false;

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    for (final c in [
      _ctcCtrl,
      _basicCtrl,
      _hraExemptCtrl,
      _c80cCtrl,
      _c80dCtrl,
      _homeLoanCtrl,
      _npsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  String get toolKey => 'salary-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'Salary breakdown';
  @override
  String get savePlaceholder => 'e.g. New job offer';

  @override
  Map<String, dynamic> collectInputs() => {
        'ctc': _ctcCtrl.text,
        'basic': _basicCtrl.text,
        'hraExempt': _hraExemptCtrl.text,
        'c80c': _c80cCtrl.text,
        'c80d': _c80dCtrl.text,
        'homeLoan': _homeLoanCtrl.text,
        'nps': _npsCtrl.text,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _ctcCtrl.text = json['ctc']?.toString() ?? '';
    _basicCtrl.text = json['basic']?.toString() ?? '40';
    _hraExemptCtrl.text = json['hraExempt']?.toString() ?? '';
    _c80cCtrl.text = json['c80c']?.toString() ?? '';
    _c80dCtrl.text = json['c80d']?.toString() ?? '';
    _homeLoanCtrl.text = json['homeLoan']?.toString() ?? '';
    _npsCtrl.text = json['nps']?.toString() ?? '';
  }

  SalaryInputs? _inputs() {
    final ctc = parseAmount(_ctcCtrl.text);
    final basicPct = parseNum(_basicCtrl.text);
    if (ctc <= 0 || basicPct <= 0) return null;
    return SalaryInputs(
      ctc: ctc,
      basicPercent: basicPct,
      hraExemptionClaimed: parseAmount(_hraExemptCtrl.text),
      deduction80C: parseAmount(_c80cCtrl.text),
      deduction80D: parseAmount(_c80dCtrl.text),
      homeLoanInterest: parseAmount(_homeLoanCtrl.text),
      npsContribution: parseAmount(_npsCtrl.text),
    );
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final i = _inputs();
    final ctc = formatter.formatCurrency(parseAmount(_ctcCtrl.text),
        symbol: currency.symbol);
    if (i == null) return 'Salary $ctc';
    final r = computeSalary(i);
    final regime = r.newIsBetter ? 'New' : 'Old';
    final monthly = formatter.formatCurrency(r.recommended.netMonthly,
        symbol: currency.symbol);
    return 'CTC $ctc → $regime regime $monthly/mo';
  }

  static const _deductionKeys = {
    'Standard Deduction',
    'HRA Exemption',
    '80C',
    '80D',
    'Home Loan Interest',
    'NPS (80CCD1B)',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    String money(double v) =>
        formatter.formatCurrency(v.roundToDouble(), symbol: currency.symbol);
    final inputs = _inputs();
    final result = inputs == null ? null : computeSalary(inputs);
    void recompute(_) => scheduleRecompute();

    String deductionCell(double v) =>
        v == 0 ? '—' : '−${money(v.abs())}';

    return ToolScreenScaffold(
      title: 'Salary Breakdown',
      subtitle: 'Your take-home pay — old regime vs new regime',
      infoConfig: InfoConstants.salaryCalculator,
      overflowConfig: savedOverflowConfig('salary'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      isSavedView: hasSaved,
      isModified: isModified,
      onUpdate: updateSaved,
      sections: [
        ToolInputCard(children: [
          ToolSliderField(
            controller: _ctcCtrl,
            label: 'ANNUAL CTC',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
            min: 300000,
            max: 10000000,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolSliderField(
            controller: _basicCtrl,
            label: 'BASIC SALARY %',
            suffix: '%',
            helper: 'Of CTC — drives HRA & PF',
            onChanged: recompute,
            min: 30,
            max: 60,
            divisions: 30,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _hraExemptCtrl,
            label: 'HRA EXEMPTION (CLAIMED)',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
          ),
          const SizedBox(height: KuberSpacing.md),
          _Expandable(
            title: 'Other components',
            expanded: _showComponents,
            onToggle: () => setState(() => _showComponents = !_showComponents),
            child: inputs == null
                ? Text('Enter a CTC to see derived components',
                    style:
                        localeFont(fontSize: 12, color: cs.onSurfaceVariant))
                : Column(
                    children: [
                      ToolStatRow(label: 'Basic', value: money(inputs.basic)),
                      const SizedBox(height: KuberSpacing.sm),
                      ToolStatRow(label: 'HRA', value: money(inputs.hra)),
                      const SizedBox(height: KuberSpacing.sm),
                      ToolStatRow(
                          label: 'Special Allowance',
                          value: money(inputs.specialAllowance)),
                      const SizedBox(height: KuberSpacing.sm),
                      ToolStatRow(
                          label: 'Employer PF',
                          value: money(inputs.employerPf)),
                      const SizedBox(height: KuberSpacing.sm),
                      ToolStatRow(
                          label: 'Gratuity', value: money(inputs.gratuity)),
                    ],
                  ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          _Expandable(
            title: 'Deductions — 80C, 80D, Home Loan, NPS',
            expanded: _showDeductions,
            onToggle: () => setState(() => _showDeductions = !_showDeductions),
            child: Column(
              children: [
                ToolTextField(
                  controller: _c80cCtrl,
                  label: '80C (up to ₹1,50,000)',
                  prefix: currency.symbol,
                  formatAsAmount: true,
                  onChanged: recompute,
                ),
                const SizedBox(height: KuberSpacing.md),
                ToolTextField(
                  controller: _c80dCtrl,
                  label: '80D (health insurance)',
                  prefix: currency.symbol,
                  formatAsAmount: true,
                  onChanged: recompute,
                ),
                const SizedBox(height: KuberSpacing.md),
                ToolTextField(
                  controller: _homeLoanCtrl,
                  label: 'Home Loan Interest (up to ₹2,00,000)',
                  prefix: currency.symbol,
                  formatAsAmount: true,
                  onChanged: recompute,
                ),
                const SizedBox(height: KuberSpacing.md),
                ToolTextField(
                  controller: _npsCtrl,
                  label: 'NPS 80CCD(1B) (up to ₹50,000)',
                  prefix: currency.symbol,
                  formatAsAmount: true,
                  onChanged: recompute,
                ),
              ],
            ),
          ),
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : ToolDualHero(
                  left: HeroSide(
                    label: 'Old Regime — Monthly',
                    value: money(result.oldRegime.netMonthly),
                    color: cs.primary,
                    sub: '${money(result.oldRegime.netAnnual)} / year',
                  ),
                  right: HeroSide(
                    label: 'New Regime — Monthly',
                    value: money(result.newRegime.netMonthly),
                    color: ToolAccents.emerald,
                    sub: '${money(result.newRegime.netAnnual)} / year',
                  ),
                  bannerText:
                      '${result.newIsBetter ? 'New' : 'Old'} regime is better for you by ${money(result.annualDifference)} / year',
                  bannerIsPositive: result.newIsBetter,
                ),
        ),
        if (result != null) ...[
          ToolSection(
            title: 'Tax & take-home',
            subtitle: 'Both regimes compared',
            child: ToolBarCompare(
              categories: const ['Old Regime', 'New Regime'],
              series: [
                BarCompareSeries(
                  name: 'Take-home',
                  color: cs.tertiary,
                  values: [
                    result.oldRegime.netAnnual,
                    result.newRegime.netAnnual
                  ],
                ),
                BarCompareSeries(
                  name: 'Total Tax',
                  color: cs.error,
                  values: [
                    result.oldRegime.totalTax,
                    result.newRegime.totalTax
                  ],
                ),
              ],
            ),
          ),
          ToolSection(
            title:
                'Recommended regime — ${result.newIsBetter ? 'New' : 'Old'}',
            subtitle: 'Take-home vs tax',
            child: ToolDonutBreakdown(
              segments: [
                BreakdownSegment(
                    'Take-home', result.recommended.netAnnual, cs.tertiary),
                BreakdownSegment(
                    'Total Tax', result.recommended.totalTax, cs.error),
              ],
              centerBig: formatter.formatCompactCurrency(
                  result.recommended.netAnnual,
                  symbol: currency.symbol),
              centerSmall: 'TAKE-HOME',
            ),
          ),
          ToolSection(
            title: 'Line-by-line',
            subtitle: 'Component • Old regime • New regime',
            child: ToolScheduleTable(
              firstColumnWidth: 150,
              dataColumnWidth: 120,
              totalRow: true,
              note:
                  'Surcharge applies only above ₹50L taxable. Slabs per FY 2025-26.',
              columns: const [
                ScheduleColumn('Component', numeric: false),
                ScheduleColumn('Old Regime'),
                ScheduleColumn('New Regime'),
              ],
              rows: [
                for (final key in result.oldRegime.breakdown.keys)
                  [
                    key,
                    _deductionKeys.contains(key)
                        ? deductionCell(result.oldRegime.breakdown[key]!)
                        : money(result.oldRegime.breakdown[key]!),
                    _deductionKeys.contains(key)
                        ? deductionCell(result.newRegime.breakdown[key]!)
                        : money(result.newRegime.breakdown[key]!),
                  ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A collapsible card row used for "Other components" and "Deductions".
class _Expandable extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _Expandable({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.md, vertical: 11),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: localeFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 18, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: KuberSpacing.md),
            child: child,
          ),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}
