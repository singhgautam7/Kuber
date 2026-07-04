// =============================================================================
// add_loan_screen.dart  — POLISHED
//
// Drop-in replacement for lib/features/loans/screens/add_loan_screen.dart.
// =============================================================================

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider, formatterProvider, NumberSystem;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/loan.dart';
import '../providers/loan_provider.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  final Loan? existing;

  /// Pre-fill support for Kuber Notes tap-to-convert (create mode only).
  final double? amountPrefill;

  const AddLoanScreen({super.key, this.existing, this.amountPrefill});

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final _principalController = TextEditingController();
  final _nameController = TextEditingController();
  final _lenderController = TextEditingController();
  final _refController = TextEditingController();
  final _emiController = TextEditingController();
  final _interestController = TextEditingController();
  final _notesController = TextEditingController();

  String _loanType = 'personal';
  String? _rateType;            // null = unset
  DateTime? _loanStartDate;     // optional disbursement
  DateTime _startDate = DateTime.now(); // required repayment start
  int _billDate = 1;
  String? _selectedAccountId;
  bool _autoAddTransaction = false;
  bool _isEditing = false;

  double get _principalAmount =>
      double.tryParse(_principalController.text.trim().replaceAll(',', '')) ??
      0;
  double get _emiAmount =>
      double.tryParse(_emiController.text.trim().replaceAll(',', '')) ?? 0;

  bool get _canSave =>
      _principalAmount > 0 &&
      _nameController.text.trim().isNotEmpty &&
      _lenderController.text.trim().isNotEmpty &&
      _emiAmount > 0 &&
      _selectedAccountId != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing == null) {
      final amount = widget.amountPrefill;
      if (amount != null && amount > 0) {
        _principalController.text = amount == amount.truncateToDouble()
            ? amount.toInt().toString()
            : amount.toStringAsFixed(2);
      }
    }
    final e = widget.existing;
    if (e != null) {
      _isEditing = true;
      _nameController.text = e.name;
      _lenderController.text = e.lenderName;
      _refController.text = e.referenceNumber ?? '';
      _principalController.text =
          e.principalAmount == e.principalAmount.truncateToDouble()
              ? e.principalAmount.toStringAsFixed(0)
              : e.principalAmount.toStringAsFixed(2);
      _emiController.text = e.emiAmount.toStringAsFixed(0);
      if (e.interestRate != null) {
        _interestController.text = e.interestRate!.toString();
      }
      _loanType = e.loanType;
      _rateType = e.rateType;
      _loanStartDate = e.loanStartDate;
      _billDate = e.billDate;
      _startDate = e.startDate;
      _selectedAccountId = e.accountId;
      _autoAddTransaction = e.autoAddTransaction;
      _notesController.text = e.notes ?? '';
    }
  }

  @override
  void dispose() {
    _principalController.dispose();
    _nameController.dispose();
    _lenderController.dispose();
    _refController.dispose();
    _emiController.dispose();
    _interestController.dispose();
    _notesController.dispose();
    super.dispose();
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
          _isEditing ? context.l10n.editLoan : context.l10n.newLoan,
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
            KuberFormSection(
              label: context.l10n.loanAmount,
              topGap: 0,
              children: [
                KuberHeroAmountInput(
                  label: context.l10n.totalPrincipal,
                  currencySymbol: symbol,
                  controller: _principalController,
                  inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
                  onChanged: (_) => setState(() {}),
                  onCalculatorTap: () =>
                      _openCalculatorFor(_principalController),
                ),
              ],
            ),
            KuberFormSection(
              label: context.l10n.loanType,
              children: [
                KuberChipGrid<String>(
                  columns: 3,
                  selected: _loanType,
                  onChanged: (v) => setState(() => _loanType = v),
                  options: [
                    KuberChipOption(
                        value: 'home', label: context.l10n.loanTypeHome, icon: Icons.home_outlined),
                    KuberChipOption(
                        value: 'vehicle',
                        label: context.l10n.loanTypeVehicle,
                        icon: Icons.directions_car_outlined),
                    KuberChipOption(
                        value: 'personal',
                        label: context.l10n.loanTypePersonal,
                        icon: Icons.person_outline_rounded),
                    KuberChipOption(
                        value: 'education',
                        label: context.l10n.loanTypeEducation,
                        icon: Icons.school_outlined),
                    KuberChipOption(
                        value: 'credit_card',
                        label: context.l10n.creditCardLabel,
                        icon: Icons.credit_card_outlined),
                    KuberChipOption(
                        value: 'other',
                        label: context.l10n.loanTypeOther,
                        icon: Icons.more_horiz_rounded),
                  ],
                ),
              ],
            ),
            KuberFormSection(
              label: context.l10n.identity,
              children: [
                KuberFieldLabel(context.l10n.loanName),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (_) => setState(() {}),
                  style: localeFont(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(hintText: context.l10n.loanNameHint),
                ),
                KuberFieldLabel(context.l10n.lenderField),
                TextField(
                  controller: _lenderController,
                  textCapitalization: TextCapitalization.words,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (_) => setState(() {}),
                  style: localeFont(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(hintText: context.l10n.lenderHint),
                ),
                KuberFieldLabel(context.l10n.referenceNumber, optional: true),
                TextField(
                  controller: _refController,
                  onChanged: (_) => setState(() {}),
                  style: localeFont(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(hintText: context.l10n.referenceNumberHint),
                ),
              ],
            ),
            KuberFormSection(
              label: context.l10n.termsLabel,
              children: [
                KuberFieldLabel(context.l10n.monthlyEmi),
                _amountFieldWithCalc(
                    controller: _emiController, symbol: symbol, isIndian: isIndian),
                KuberFieldLabel(context.l10n.interestRate, optional: true),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _interestController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        onChanged: (_) => setState(() {}),
                        style: localeFont(
                            color: cs.onSurface, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'e.g. 8.45',
                          suffixText: '%',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ratePill(context.l10n.rateFixed, 'fixed'),
                    const SizedBox(width: 6),
                    _ratePill(context.l10n.rateFloating, 'floating'),
                  ],
                ),
              ],
            ),

            // ── ANSWER CARD ──────────────────────────────────────────
            if (_emiAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: KuberAnswerCard(
                  labelText: context.l10n.monthlyOutflow,
                  labelIcon: Icons.bolt_rounded,
                  amountText: '$symbol${_formatThousands(_emiAmount)}',
                  unitText: context.l10n.perMonth,
                  meta: _principalAmount > 0
                      ? [
                          KuberAnswerMeta(
                            key: context.l10n.principal,
                            value: '$symbol${_compactL(_principalAmount)}',
                          ),
                          KuberAnswerMeta(
                            key: context.l10n.tenure,
                            value: '— mo',
                          ),
                          KuberAnswerMeta(
                            key: context.l10n.interestLabel,
                            value: '—',
                          ),
                        ]
                      : const [],
                ),
              ),

            // ── SCHEDULE (tinted) ────────────────────────────────────
            KuberFormSection(
              label: context.l10n.schedule,
              tinted: true,
              children: [
                KuberFieldLabel(context.l10n.loanStartDate,
                    optional: true),
                _loanStartDateRow(),
                KuberFieldLabel(context.l10n.repaymentStart),
                _dateRow(
                  label: context.l10n.firstEmiOn,
                  date: _startDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                ),
                KuberFieldLabel(context.l10n.monthlyBillDate),
                KuberDayGrid(
                  selected: _billDate,
                  onChanged: (v) => setState(() => _billDate = v),
                ),
              ],
            ),

            KuberFormSection(
              label: context.l10n.sourceAccount,
              children: [
                _accountPickerRow(),
                KuberSwitchRow(
                  icon: Icons.bolt_rounded,
                  name: context.l10n.autoAddTransactions,
                  sub: context.l10n.autoAddTransactionsSub,
                  value: _autoAddTransaction,
                  onChanged: (v) => setState(() => _autoAddTransaction = v),
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
                    hintText: context.l10n.loanNotesHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: KuberSaveButton(
        label: _isEditing ? context.l10n.saveChanges : context.l10n.confirmAddLoan,
        onPressed: _canSave ? _save : null,
      ),
    );
  }

  // ── widgets ─────────────────────────────────────────────────────
  Widget _amountFieldWithCalc({
    required TextEditingController controller,
    required String symbol,
    required bool isIndian,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
      onChanged: (_) => setState(() {}),
      style: localeFont(color: cs.onSurface, fontSize: 15),
      decoration: InputDecoration(
        prefixText: '$symbol ',
        prefixStyle: localeFont(color: cs.onSurfaceVariant),
        suffixIcon: IconButton(
          icon: Icon(Icons.calculate_outlined,
              size: 18, color: cs.onSurfaceVariant),
          onPressed: () => _openCalculatorFor(controller),
        ),
      ),
    );
  }

  Widget _ratePill(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final selected = _rateType == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() {
          _rateType = selected ? null : value;
        }),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.12)
                : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? cs.primary : cs.outline,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loanStartDateRow() {
    final cs = Theme.of(context).colorScheme;
    if (_loanStartDate == null) {
      return KuberPickerRow(
        leading: KuberLeadingSwatch(
          color: cs.surfaceContainerHigh,
          icon: Icons.calendar_today_rounded,
          empty: true,
        ),
        label: context.l10n.disbursedOn,
        value: context.l10n.notSetTapToAdd,
        valueIsPlaceholder: true,
        onTap: _pickLoanStartDate,
      );
    }
    return KuberPickerRow(
      leading: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Icon(Icons.calendar_today_rounded,
            size: 16, color: cs.onSurface),
      ),
      label: context.l10n.disbursedOn,
      value: DateFormat('d MMM yyyy').format(_loanStartDate!),
      onTap: _pickLoanStartDate,
      clearable: true,
      onClear: () => setState(() => _loanStartDate = null),
    );
  }

  Widget _dateRow({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return KuberPickerRow(
      leading: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Icon(Icons.calendar_today_rounded,
            size: 16, color: cs.onSurface),
      ),
      label: label,
      value: DateFormat('d MMM yyyy').format(date),
      onTap: onTap,
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
      label: context.l10n.emiDebitedFrom,
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

  // ── PRESERVED handlers ──────────────────────────────────────────
  Future<void> _pickLoanStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _loanStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    ).unfocusOnComplete(context);
    if (picked != null) setState(() => _loanStartDate = picked);
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
    final cats = await ref.read(categoryRepositoryProvider).getAll();
    final emiCategory = cats.firstWhere(
      (c) => c.name == 'Loan EMI',
      orElse: () => cats.first,
    );

    final emi = _emiAmount;
    final interest = double.tryParse(
        _interestController.text.trim().replaceAll(',', ''));

    if (_isEditing) {
      final loan = widget.existing!
        ..name = _nameController.text.trim()
        ..loanType = _loanType
        ..lenderName = _lenderController.text.trim()
        ..referenceNumber = _refController.text.trim().isEmpty
            ? null
            : _refController.text.trim()
        ..principalAmount = _principalAmount
        ..emiAmount = emi
        ..rateType = _rateType
        ..interestRate = interest
        ..loanStartDate = _loanStartDate
        ..billDate = _billDate
        ..startDate = _startDate
        ..accountId = _selectedAccountId!
        ..categoryId = emiCategory.id.toString()
        ..autoAddTransaction = _autoAddTransaction
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim();

      await ref.read(loanListProvider.notifier).updateLoan(loan);
    } else {
      await ref.read(loanListProvider.notifier).addLoan(
            name: _nameController.text.trim(),
            loanType: _loanType,
            lenderName: _lenderController.text.trim(),
            referenceNumber: _refController.text.trim().isEmpty
                ? null
                : _refController.text.trim(),
            principalAmount: _principalAmount,
            emiAmount: emi,
            rateType: _rateType,
            interestRate: interest,
            loanStartDate: _loanStartDate,
            billDate: _billDate,
            startDate: _startDate,
            accountId: _selectedAccountId!,
            categoryId: emiCategory.id.toString(),
            autoAddTransaction: _autoAddTransaction,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
    }
    if (mounted) context.pop();
  }
}

// Number helpers
String _formatThousands(double v) =>
    NumberFormat('#,##,##0', 'en_IN').format(v);
String _compactL(double v) {
  if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(2)}Cr';
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}