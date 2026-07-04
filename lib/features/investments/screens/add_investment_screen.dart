// =============================================================================
// add_investment_screen.dart  — POLISHED
//
// Drop-in replacement for
//   lib/features/investments/screens/add_investment_screen.dart
// =============================================================================

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider, formatterProvider, NumberSystem;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/investment.dart';
import '../providers/investment_provider.dart';

class AddInvestmentScreen extends ConsumerStatefulWidget {
  final Investment? existing;

  /// Pre-fill support for Kuber Notes tap-to-convert (create mode only).
  final double? amountPrefill;

  const AddInvestmentScreen({super.key, this.existing, this.amountPrefill});

  @override
  ConsumerState<AddInvestmentScreen> createState() =>
      _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _nameController = TextEditingController();
  final _investedController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _sipAmountController = TextEditingController();
  final _notesController = TextEditingController();

  String _investmentType = 'stocks';
  bool _autoDebit = false;
  int? _sipDate;
  String? _selectedAccountId;
  bool _isEditing = false;
  bool _deductedFromAccount = true;

  @override
  void initState() {
    super.initState();
    if (widget.existing == null) {
      final amount = widget.amountPrefill;
      if (amount != null && amount > 0) {
        _investedController.text = amount == amount.truncateToDouble()
            ? amount.toInt().toString()
            : amount.toStringAsFixed(2);
      }
    }
    final e = widget.existing;
    if (e != null) {
      _isEditing = true;
      _nameController.text = e.name;
      _investmentType = e.investmentType;
      if (e.currentValue != null) {
        _currentValueController.text = e.currentValue!.toStringAsFixed(0);
      }
      if (e.investedAmount != null) {
        _investedController.text = e.investedAmount!.toStringAsFixed(0);
      }
      _autoDebit = e.autoDebit;
      if (e.sipAmount != null) {
        _sipAmountController.text = e.sipAmount!.toStringAsFixed(0);
      }
      _sipDate = e.sipDate;
      _selectedAccountId = e.accountId;
      _notesController.text = e.notes ?? '';
      _deductedFromAccount = e.deductedFromAccount;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentValueController.dispose();
    _sipAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _invested =>
      double.tryParse(_investedController.text.trim().replaceAll(',', '')) ??
      0;
  double get _current =>
      double.tryParse(
          _currentValueController.text.trim().replaceAll(',', '')) ??
      0;
  double get _sipAmount =>
      double.tryParse(_sipAmountController.text.trim().replaceAll(',', '')) ??
      0;

  bool get _canSave {
    if (_nameController.text.trim().isEmpty) return false;
    if (_autoDebit) {
      if (_sipAmount <= 0 || _sipDate == null) {
        return false;
      }
    }
    final showAccountPicker = _autoDebit || (_deductedFromAccount && _invested > 0);
    if (showAccountPicker && _selectedAccountId == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final isIndian = ref.watch(formatterProvider).system == NumberSystem.indian;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? context.l10n.editInvestment : context.l10n.newInvestment,
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── IDENTITY ─────────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.identity,
              topGap: 0,
              children: [
                KuberFieldLabel(context.l10n.investmentName),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (_) => setState(() {}),
                  style: localeFont(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: context.l10n.investmentNameHint,
                  ),
                ),
              ],
            ),

            KuberFormSection(
              label: context.l10n.typeLabel,
              children: [
                KuberChipGrid<String>(
                  columns: 3,
                  selected: _investmentType,
                  onChanged: (v) => setState(() => _investmentType = v),
                  options: [
                    KuberChipOption(
                        value: 'sip',
                        label: context.l10n.invTypeSip,
                        icon: Icons.savings_outlined),
                    KuberChipOption(
                        value: 'mutual_fund',
                        label: context.l10n.invTypeMutualFund,
                        icon: Icons.pie_chart_outline),
                    KuberChipOption(
                        value: 'stocks',
                        label: context.l10n.invTypeStocks,
                        icon: Icons.show_chart_rounded),
                    KuberChipOption(
                        value: 'etf',
                        label: context.l10n.invTypeEtf,
                        icon: Icons.layers_outlined),
                    KuberChipOption(
                        value: 'bonds',
                        label: context.l10n.invTypeBonds,
                        icon: Icons.description_outlined),
                    KuberChipOption(
                        value: 'gold',
                        label: context.l10n.invTypeGold,
                        icon: Icons.diamond_outlined),
                    KuberChipOption(
                        value: 'real_estate',
                        label: context.l10n.invTypeRealEstate,
                        icon: Icons.home_work_outlined),
                    KuberChipOption(
                        value: 'crypto',
                        label: context.l10n.invTypeCrypto,
                        icon: Icons.currency_bitcoin_rounded),
                    KuberChipOption(
                        value: 'fd',
                        label: context.l10n.invTypeFd,
                        icon: Icons.account_balance_outlined),
                    KuberChipOption(
                        value: 'rd',
                        label: context.l10n.invTypeRd,
                        icon: Icons.savings_rounded),
                    KuberChipOption(
                        value: 'collectible',
                        label: context.l10n.invTypeCollectible,
                        icon: Icons.palette_outlined),
                    KuberChipOption(
                        value: 'other',
                        label: context.l10n.invTypeOther,
                        icon: Icons.more_horiz_rounded),
                  ],
                ),
              ],
            ),

            KuberFormSection(
              label: context.l10n.valueLabel,
              children: [
                KuberFieldLabel(_isEditing
                    ? context.l10n.totalInvestedInclNew
                    : context.l10n.investedAmountInitial),
                TextField(
                  controller: _investedController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
                  onChanged: (_) => setState(() {}),
                  style: localeFont(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    prefixText: '$symbol ',
                    prefixStyle: localeFont(
                        color: cs.onSurfaceVariant),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          _openCalculatorFor(_investedController),
                      icon: Icon(Icons.calculate_outlined,
                          size: 18, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                KuberHeroAmountInput(
                  label: context.l10n.currentValueLabel,
                  currencySymbol: symbol,
                  controller: _currentValueController,
                  inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
                  onChanged: (_) => setState(() {}),
                  onCalculatorTap: () =>
                      _openCalculatorFor(_currentValueController),
                ),
                // Moved "Already invested?" toggle to Auto-debit & Account section below
                if (_invested > 0 && _current > 0) ...[
                  const SizedBox(height: 10),
                  _GainLossChip(
                    invested: _invested,
                    current: _current,
                    symbol: symbol,
                  ),
                ],
              ],
            ),

            KuberFormSection(
              label: "Automation & Account",
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KuberSwitchRow(
                      icon: Icons.repeat_rounded,
                      name: context.l10n.enableAutoDebitSip,
                      sub: context.l10n.automateMonthlyContrib,
                      value: _autoDebit,
                      onChanged: (v) => setState(() => _autoDebit = v),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: !_autoDebit
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  KuberFieldLabel(context.l10n.monthlySipAmount),
                                  TextField(
                                    controller: _sipAmountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
                                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                    onChanged: (_) => setState(() {}),
                                    style: localeFont(
                                        color: cs.onSurface, fontSize: 15),
                                    decoration: InputDecoration(
                                      prefixText: '$symbol ',
                                      prefixStyle: localeFont(
                                          color: cs.onSurfaceVariant),
                                      suffixIcon: IconButton(
                                        onPressed: () => _openCalculatorFor(
                                            _sipAmountController),
                                        icon: Icon(Icons.calculate_outlined,
                                            size: 18,
                                            color: cs.onSurfaceVariant),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  KuberFieldLabel(context.l10n.sipDate),
                                  KuberDayGrid(
                                    selected: _sipDate,
                                    onChanged: (v) => setState(() => _sipDate = v),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KuberSwitchRow(
                      icon: Icons.check_circle_outline_rounded,
                      name: "Already invested?",
                      sub: _isEditing
                          ? "Set at creation. To change, delete and re-add."
                          : "If turned on, the amount won't be deducted from your selected account. Use this for investments you made before adding Kuber.",
                      value: !_deductedFromAccount,
                      enabled: !_isEditing,
                      onChanged: (v) => setState(() => _deductedFromAccount = !v),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: !(_autoDebit || (_deductedFromAccount && _invested > 0))
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  KuberFieldLabel(context.l10n.debitedFrom),
                                  _accountPickerRow(),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),

            KuberFormSection(
              label: context.l10n.notesLabel,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  style: localeFont(color: cs.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.l10n.optionalContext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: KuberSaveButton(
        label: _isEditing ? context.l10n.saveChanges : context.l10n.addInvestment,
        onPressed: _canSave ? _save : null,
      ),
    );
  }

  Widget _accountPickerRow() {
    final accs = ref.watch(accountListProvider).valueOrNull ?? [];
    final acc = _selectedAccountId == null
        ? null
        : accs
            .where((a) => a.id.toString() == _selectedAccountId)
            .firstOrNull;
    return KuberPickerRow(
      leading: acc == null
          ? KuberLeadingSwatch(
              color: Colors.transparent,
              icon: Icons.account_balance_outlined,
              empty: true,
            )
          : KuberLeadingSwatch(
              color: Color(acc.colorValue ?? 0xFF3B82F6),
              icon: IconMapper.fromString(acc.icon ?? 'account_balance'),
            ),
      label: context.l10n.accountTitle,
      value: acc?.name ?? context.l10n.selectAccountTitle,
      valueIsPlaceholder: acc == null,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => AccountPickerSheet(
            selectedAccountId: int.tryParse(_selectedAccountId ?? ''),
            onSelected: (id) {
              setState(() => _selectedAccountId = id.toString());
              Navigator.pop(context);
            },
          ),
        ).unfocusOnComplete(context);
      },
    );
  }

  void _openCalculatorFor(TextEditingController controller) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => KuberCalculator(
        initialValue: double.tryParse(controller.text.trim().replaceAll(',', '')) ?? 0,
        onConfirm: (result) {
          setState(() {
            controller.text = result == result.truncateToDouble()
                ? result.toInt().toString()
                : result.toStringAsFixed(2);
          });
        },
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
  }

  // PRESERVED VERBATIM ─────────────────────────────────────────────
  Future<void> _save() async {
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    final investCat = categories.firstWhere(
      (c) => c.name == 'Investment',
      orElse: () => categories.first,
    );

    final sipAmount = _autoDebit ? _sipAmount : null;

    if (_isEditing) {
      final existing = widget.existing!;
      final desiredInvested = _invested > 0
          ? _invested
          : existing.investedAmount ?? 0;
      double? currentValue = _current > 0 ? _current : null;
      currentValue ??= desiredInvested > 0
          ? desiredInvested
          : existing.currentValue;

      final updated = existing
        ..name = _nameController.text.trim()
        ..investmentType = _investmentType
        ..investedAmount = desiredInvested
        ..currentValue = currentValue
        ..autoDebit = _autoDebit
        ..sipAmount = sipAmount
        ..sipDate = _autoDebit ? _sipDate : null
        ..accountId = _selectedAccountId ?? existing.accountId
        ..categoryId = investCat.id.toString()
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim();
      await ref.read(investmentListProvider.notifier).updateInvestment(updated);
    } else {
      final initialAmount = _invested;
      double? currentValue = _current > 0 ? _current : null;
      currentValue ??= initialAmount > 0 ? initialAmount : null;
      await ref.read(investmentListProvider.notifier).addInvestment(
            name: _nameController.text.trim(),
            investmentType: _investmentType,
            currentValue: currentValue,
            autoDebit: _autoDebit,
            sipAmount: sipAmount,
            sipDate: _autoDebit ? _sipDate : null,
            accountId: _selectedAccountId,
            categoryId: investCat.id.toString(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            initialAmount: initialAmount,
            deductedFromAccount: _deductedFromAccount,
          );
    }
    if (mounted) context.pop();
  }
}

// ─── derived gain/loss chip ─────────────────────────────────────────
class _GainLossChip extends StatelessWidget {
  final double invested;
  final double current;
  final String symbol;
  const _GainLossChip({
    required this.invested,
    required this.current,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final delta = current - invested;
    final pct = invested == 0 ? 0 : (delta / invested) * 100;
    final positive = delta >= 0;
    final tone = positive ? cs.tertiary : cs.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: tone.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(
            positive
                ? Icons.arrow_outward_rounded
                : Icons.south_west_rounded,
            size: 14,
            color: tone,
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      '${positive ? '+' : '−'}$symbol${delta.abs().toStringAsFixed(0)}',
                  style: localeFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tone,
                  ),
                ),
                TextSpan(
                  text:
                      ' · ${positive ? '+' : '−'}${pct.abs().toStringAsFixed(2)}%',
                  style: localeFont(
                    fontSize: 12,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}