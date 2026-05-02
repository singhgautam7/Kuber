import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

class SalaryCalculatorScreen extends ConsumerStatefulWidget {
  const SalaryCalculatorScreen({super.key});

  @override
  ConsumerState<SalaryCalculatorScreen> createState() =>
      _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState
    extends ConsumerState<SalaryCalculatorScreen> {
  final _ctcCtrl = TextEditingController();
  final _basicPctCtrl = TextEditingController(text: '40');
  final _profTaxCtrl = TextEditingController(text: '200');
  double _basicPct = 40;
  int _regimeIndex = 0; // 0 = New, 1 = Old
  bool _profTaxEnabled = true;
  int _cityIndex = 0; // 0 = Metro, 1 = Non-Metro
  bool _showBreakdown = false;

  @override
  void dispose() {
    _ctcCtrl.dispose();
    _basicPctCtrl.dispose();
    _profTaxCtrl.dispose();
    super.dispose();
  }

  void _onSliderChanged(double v) {
    setState(() {
      _basicPct = v;
      _basicPctCtrl.text = v.toStringAsFixed(0);
    });
  }

  void _onBasicPctTextChanged(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed >= 10 && parsed <= 80) {
      setState(() => _basicPct = parsed);
    }
  }

  double _calcTax(double taxableIncome, bool newRegime) {
    if (newRegime) {
      // New regime slabs FY 2025-26
      const slabs = [
        (4000000.0, 0.0),
        (8000000.0, 0.05),
        (12000000.0, 0.10),
        (16000000.0, 0.15),
        (20000000.0, 0.20),
        (24000000.0, 0.25),
        (double.infinity, 0.30),
      ];
      double tax = 0;
      double prev = 0;
      for (final (upper, rate) in slabs) {
        if (taxableIncome <= prev) break;
        final taxable = (taxableIncome < upper ? taxableIncome : upper) - prev;
        tax += taxable * rate;
        prev = upper;
      }
      return tax * 1.04; // 4% cess
    } else {
      // Old regime slabs
      const slabs = [
        (250000.0, 0.0),
        (500000.0, 0.05),
        (1000000.0, 0.20),
        (double.infinity, 0.30),
      ];
      double tax = 0;
      double prev = 0;
      for (final (upper, rate) in slabs) {
        if (taxableIncome <= prev) break;
        final taxable = (taxableIncome < upper ? taxableIncome : upper) - prev;
        tax += taxable * rate;
        prev = upper;
      }
      return tax * 1.04;
    }
  }

  ({
    double monthlyInHand,
    double annualGross,
    double incomeTaxAnnual,
    double employeePfMonthly,
    double profTaxMonthly,
    double totalDeductionsAnnual,
    double basic,
    double hra,
    double specialAllowance,
    double gratuity,
  })? _compute() {
    final ctc = double.tryParse(_ctcCtrl.text.replaceAll(',', ''));
    if (ctc == null || ctc <= 0) return null;
    final profTaxMonthly = _profTaxEnabled
        ? (double.tryParse(_profTaxCtrl.text) ?? 200)
        : 0.0;

    final pct = _basicPct / 100;
    final basic = ctc * pct;
    final hra = basic * (_cityIndex == 0 ? 0.5 : 0.4);
    final employeePfMonthly = (basic / 12).clamp(0, 15000) * 0.12;
    final employerPfAnnual = employeePfMonthly * 12;
    final gratuity = basic * 0.0481;
    final specialAllowance =
        ctc - basic - hra - employerPfAnnual - gratuity;

    // Taxable income
    final grossIncome = basic + hra + specialAllowance;
    final standardDed = _regimeIndex == 0 ? 75000.0 : 50000.0;
    double taxableIncome = grossIncome - standardDed;
    if (_regimeIndex == 1) {
      // Old regime: 80C deduction up to 1.5L (employee PF contribution counts)
      final pf80c = (employeePfMonthly * 12).clamp(0, 150000);
      taxableIncome -= pf80c;
    }
    if (taxableIncome < 0) taxableIncome = 0;

    final incomeTaxAnnual =
        _calcTax(taxableIncome, _regimeIndex == 0);

    final totalDeductionsAnnual = employeePfMonthly * 12 +
        profTaxMonthly * 12 +
        incomeTaxAnnual +
        gratuity;
    final monthlyInHand = (ctc - totalDeductionsAnnual) / 12;

    return (
      monthlyInHand: monthlyInHand,
      annualGross: grossIncome,
      incomeTaxAnnual: incomeTaxAnnual,
      employeePfMonthly: employeePfMonthly,
      profTaxMonthly: profTaxMonthly,
      totalDeductionsAnnual: totalDeductionsAnnual,
      basic: basic,
      hra: hra,
      specialAllowance: specialAllowance,
      gratuity: gratuity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final result = _compute();

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.salaryCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Salary Breakdown',
              description: 'Calculate your in-hand salary',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ToolInputCard(
                  children: [
                    ToolTextField(
                      label: 'ANNUAL CTC',
                      controller: _ctcCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('BASIC SALARY % OF CTC'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolTextField(
                      controller: _basicPctCtrl,
                      suffix: '%',
                      onChanged: _onBasicPctTextChanged,
                    ),
                    Slider(
                      value: _basicPct.clamp(10, 80),
                      min: 10,
                      max: 80,
                      divisions: 70,
                      activeColor: cs.primary,
                      inactiveColor: cs.outline,
                      label: '${_basicPct.toStringAsFixed(0)}%',
                      onChanged: _onSliderChanged,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('10%',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                        Text('80%',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('TAX REGIME'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolSegmentedControl(
                      labels: const ['NEW REGIME', 'OLD REGIME'],
                      selectedIndex: _regimeIndex,
                      onChanged: (i) => setState(() => _regimeIndex = i),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('CITY TYPE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolSegmentedControl(
                      labels: const ['METRO', 'NON-METRO'],
                      selectedIndex: _cityIndex,
                      onChanged: (i) => setState(() => _cityIndex = i),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ToolInputLabel('PROFESSIONAL TAX'),
                        Switch(
                          value: _profTaxEnabled,
                          activeThumbColor: cs.primary,
                          onChanged: (v) =>
                              setState(() => _profTaxEnabled = v),
                        ),
                      ],
                    ),
                    if (_profTaxEnabled) ...[
                      const SizedBox(height: KuberSpacing.sm),
                      ToolTextField(
                        label: 'MONTHLY PROFESSIONAL TAX',
                        controller: _profTaxCtrl,
                        prefix: currency.symbol,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: 'Monthly In-Hand',
                            value: formatter.formatCurrency(
                                result.monthlyInHand,
                                symbol: currency.symbol),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'Annual Gross Salary',
                            value: formatter.formatCurrency(
                                result.annualGross,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Income Tax (Annual)',
                            value: formatter.formatCurrency(
                                result.incomeTaxAnnual,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'PF Deduction (Monthly)',
                            value: formatter.formatCurrency(
                                result.employeePfMonthly,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          if (_profTaxEnabled) ...[
                            const SizedBox(height: KuberSpacing.sm),
                            ToolStatRow(
                              label: 'Professional Tax (Monthly)',
                              value: formatter.formatCurrency(
                                  result.profTaxMonthly,
                                  symbol: currency.symbol),
                              valueColor: cs.error,
                            ),
                          ],
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'Total Deductions (Annual)',
                            value: formatter.formatCurrency(
                                result.totalDeductionsAnnual,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showBreakdown = !_showBreakdown),
                            child: Row(
                              children: [
                                Text(
                                  'Full Breakdown',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                                const SizedBox(width: KuberSpacing.xs),
                                Icon(
                                  _showBreakdown
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: cs.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          if (_showBreakdown) ...[
                            const SizedBox(height: KuberSpacing.md),
                            Divider(
                                color: cs.outline.withValues(alpha: 0.4),
                                height: 1),
                            const SizedBox(height: KuberSpacing.md),
                            ToolStatRow(
                              label: 'Basic Salary (Annual)',
                              value: formatter.formatCurrency(result.basic,
                                  symbol: currency.symbol),
                            ),
                            const SizedBox(height: KuberSpacing.sm),
                            ToolStatRow(
                              label: 'HRA (Annual)',
                              value: formatter.formatCurrency(result.hra,
                                  symbol: currency.symbol),
                            ),
                            const SizedBox(height: KuberSpacing.sm),
                            ToolStatRow(
                              label: 'Special Allowance (Annual)',
                              value: formatter.formatCurrency(
                                  result.specialAllowance,
                                  symbol: currency.symbol),
                            ),
                            const SizedBox(height: KuberSpacing.sm),
                            ToolStatRow(
                              label: 'Employee PF (Annual)',
                              value: formatter.formatCurrency(
                                  result.employeePfMonthly * 12,
                                  symbol: currency.symbol),
                            ),
                            const SizedBox(height: KuberSpacing.sm),
                            ToolStatRow(
                              label: 'Gratuity (Annual)',
                              value: formatter.formatCurrency(result.gratuity,
                                  symbol: currency.symbol),
                            ),
                          ],
                        ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
