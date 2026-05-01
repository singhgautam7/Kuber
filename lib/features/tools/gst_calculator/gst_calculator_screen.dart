import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

const _kGstPresets = [5.0, 12.0, 18.0, 28.0];

class GstCalculatorScreen extends ConsumerStatefulWidget {
  const GstCalculatorScreen({super.key});

  @override
  ConsumerState<GstCalculatorScreen> createState() =>
      _GstCalculatorScreenState();
}

class _GstCalculatorScreenState extends ConsumerState<GstCalculatorScreen> {
  final _amountCtrl = TextEditingController();
  final _customRateCtrl = TextEditingController();
  double? _selectedPreset = 18.0;
  bool _isCustom = false;
  int _modeIndex = 0; // 0 = Add GST, 1 = Remove GST

  @override
  void dispose() {
    _amountCtrl.dispose();
    _customRateCtrl.dispose();
    super.dispose();
  }

  double? get _rate {
    if (_isCustom) return double.tryParse(_customRateCtrl.text);
    return _selectedPreset;
  }

  ({double gstAmount, double baseAmount, double cgst, double sgst})? _compute() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    final rate = _rate;
    if (amount == null || rate == null) return null;
    if (amount <= 0 || rate <= 0) return null;

    double gstAmount;
    double baseAmount;

    if (_modeIndex == 0) {
      gstAmount = amount * rate / 100;
      baseAmount = amount;
    } else {
      baseAmount = amount * 100 / (100 + rate);
      gstAmount = amount - baseAmount;
    }

    return (
      gstAmount: gstAmount,
      baseAmount: baseAmount,
      cgst: gstAmount / 2,
      sgst: gstAmount / 2,
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
              infoConfig: InfoConstants.gstCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'GST Calculator',
              description: 'Add or remove GST instantly',
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
                      label: 'AMOUNT',
                      controller: _amountCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('GST RATE'),
                    const SizedBox(height: KuberSpacing.sm),
                    Row(
                      children: [
                        ..._kGstPresets.map((preset) {
                          final selected =
                              !_isCustom && _selectedPreset == preset;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: KuberSpacing.xs),
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _isCustom = false;
                                  _selectedPreset = preset;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: KuberSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? cs.primary
                                        : cs.surfaceContainerHigh,
                                    borderRadius:
                                        BorderRadius.circular(KuberRadius.md),
                                    border: Border.all(
                                      color: selected ? cs.primary : cs.outline,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${preset.toStringAsFixed(0)}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : cs.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isCustom = true;
                              _selectedPreset = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                vertical: KuberSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: _isCustom
                                    ? cs.primary
                                    : cs.surfaceContainerHigh,
                                borderRadius:
                                    BorderRadius.circular(KuberRadius.md),
                                border: Border.all(
                                  color: _isCustom ? cs.primary : cs.outline,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Custom',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isCustom ? Colors.white : cs.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isCustom) ...[
                      const SizedBox(height: KuberSpacing.md),
                      ToolTextField(
                        label: 'CUSTOM RATE',
                        controller: _customRateCtrl,
                        suffix: '%',
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('MODE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ToolSegmentedControl(
                      labels: const ['ADD GST', 'REMOVE GST'],
                      selectedIndex: _modeIndex,
                      onChanged: (i) => setState(() => _modeIndex = i),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: result == null
                      ? [const ToolEmptyResult()]
                      : [
                          ToolHeroResult(
                            label: _modeIndex == 0
                                ? 'Total (with GST)'
                                : 'Original Amount',
                            value: formatter.formatCurrency(
                              _modeIndex == 0
                                  ? result.baseAmount + result.gstAmount
                                  : result.baseAmount,
                              symbol: currency.symbol,
                            ),
                            color: cs.primary,
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          ToolStatRow(
                            label: 'GST Amount',
                            value: formatter.formatCurrency(result.gstAmount,
                                symbol: currency.symbol),
                            valueColor: cs.error,
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'CGST',
                            value: formatter.formatCurrency(result.cgst,
                                symbol: currency.symbol),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          ToolStatRow(
                            label: 'SGST',
                            value: formatter.formatCurrency(result.sgst,
                                symbol: currency.symbol),
                          ),
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
