import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/hra_engine.dart';
import '../widgets/calculator_hero_result.dart';
import '../widgets/calculator_screen_scaffold.dart';
import '../widgets/calculator_support.dart';
import '../widgets/calculator_widgets.dart';

class HraCalculatorScreen extends ConsumerStatefulWidget {
  final int? savedId;
  const HraCalculatorScreen({super.key, this.savedId});

  @override
  ConsumerState<HraCalculatorScreen> createState() =>
      _HraCalculatorScreenState();
}

class _HraCalculatorScreenState extends ConsumerState<HraCalculatorScreen>
    with CalculatorSupport {
  final _basicCtrl = TextEditingController();
  final _hraCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  int _city = 0; // 0 = Metro, 1 = Non-metro

  @override
  void initState() {
    super.initState();
    initCalculatorSupport();
  }

  @override
  void dispose() {
    _basicCtrl.dispose();
    _hraCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  @override
  String get toolKey => 'hra-calculator';
  @override
  int? get initialSavedId => widget.savedId;
  @override
  String get defaultSaveName => 'HRA exemption';
  @override
  String get savePlaceholder => 'e.g. FY25 HRA claim';

  bool get _isMetro => _city == 0;

  @override
  Map<String, dynamic> collectInputs() => {
        'basic': _basicCtrl.text,
        'hra': _hraCtrl.text,
        'rent': _rentCtrl.text,
        'city': _city,
      };

  @override
  void applyInputs(Map<String, dynamic> json) {
    _basicCtrl.text = json['basic']?.toString() ?? '';
    _hraCtrl.text = json['hra']?.toString() ?? '';
    _rentCtrl.text = json['rent']?.toString() ?? '';
    _city = json['city'] as int? ?? 0;
  }

  HraResult? _compute() {
    final basic = parseAmount(_basicCtrl.text);
    final hra = parseAmount(_hraCtrl.text);
    final rent = parseAmount(_rentCtrl.text);
    if (basic <= 0 || hra <= 0 || rent <= 0) return null;
    return computeHra(
        basic: basic, hraReceived: hra, rentPaid: rent, isMetro: _isMetro);
  }

  @override
  String buildSummary() {
    final formatter = ref.read(formatterProvider);
    final currency = ref.read(currencyProvider);
    final r = _compute();
    if (r == null) return 'HRA exemption';
    return 'Exempt ${formatter.formatCurrency(r.exemption, symbol: currency.symbol)} • Taxable ${formatter.formatCurrency(r.taxableHra, symbol: currency.symbol)}';
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
      title: 'HRA Exemption',
      subtitle: 'The exempt and taxable portions of your HRA',
      infoConfig: InfoConstants.hraCalculator,
      overflowConfig: savedOverflowConfig('HRA'),
      banner: buildSavedBanner(),
      onSave: openSaveSheet,
      canSave: result != null,
      sections: [
        ToolInputCard(children: [
          ToolTextField(
            controller: _basicCtrl,
            label: 'BASIC SALARY (ANNUAL)',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _hraCtrl,
            label: 'HRA RECEIVED (ANNUAL)',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
          ),
          const SizedBox(height: KuberSpacing.lg),
          ToolTextField(
            controller: _rentCtrl,
            label: 'RENT PAID (ANNUAL)',
            prefix: currency.symbol,
            formatAsAmount: true,
            onChanged: recompute,
          ),
          const SizedBox(height: KuberSpacing.lg),
          const ToolInputLabel('CITY'),
          const SizedBox(height: KuberSpacing.sm),
          ToolSegmentedControl(
            labels: const ['Metro', 'Non-metro'],
            selectedIndex: _city,
            onChanged: (i) => setState(() => _city = i),
          ),
        ]),
        ToolSection(
          title: 'Result',
          child: result == null
              ? const ToolEmptyResult()
              : ToolDualHero(
                  left: HeroSide(
                    label: 'HRA Exemption',
                    value: money(result.exemption),
                    color: cs.tertiary,
                  ),
                  right: HeroSide(
                    label: 'Taxable HRA',
                    value: money(result.taxableHra),
                    color: cs.error,
                  ),
                ),
        ),
        if (result != null)
          ToolSection(
            title: 'How it was determined',
            subtitle: 'Exemption = least of the three',
            child: Column(
              children: [
                _MethodRow(
                  label: 'HRA received',
                  value: money(result.methodHraReceived),
                  isWinner: result.winningMethod == 0,
                ),
                const SizedBox(height: 9),
                _MethodRow(
                  label: 'Rent paid − 10% of Basic',
                  value: money(result.methodRentMinus10Basic),
                  isWinner: result.winningMethod == 1,
                ),
                const SizedBox(height: 9),
                _MethodRow(
                  label: _isMetro
                      ? '50% of Basic (metro)'
                      : '40% of Basic (non-metro)',
                  value: money(result.methodPercentOfBasic),
                  isWinner: result.winningMethod == 2,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isWinner;
  const _MethodRow(
      {required this.label, required this.value, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner
            ? cs.tertiary.withValues(alpha: 0.10)
            : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
            color: isWinner ? cs.tertiary.withValues(alpha: 0.35) : cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isWinner ? cs.tertiary : Colors.transparent,
              shape: BoxShape.circle,
              border: isWinner ? null : Border.all(color: cs.outline, width: 1.5),
            ),
            child: isWinner
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: localeFont(
                fontSize: 12.5,
                fontWeight: isWinner ? FontWeight.w600 : FontWeight.w400,
                color: isWinner ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isWinner ? cs.tertiary : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
