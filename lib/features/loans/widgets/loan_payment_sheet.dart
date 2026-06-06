import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/loan.dart';
import '../providers/loan_provider.dart';

class LoanPaymentSheet extends ConsumerStatefulWidget {
  final Loan loan;
  final bool isEmi;
  final bool isClosure;

  const LoanPaymentSheet({
    super.key,
    required this.loan,
    this.isEmi = true,
    this.isClosure = false,
  });

  @override
  ConsumerState<LoanPaymentSheet> createState() => _LoanPaymentSheetState();
}

class _LoanPaymentSheetState extends ConsumerState<LoanPaymentSheet> {
  final _amountController = TextEditingController();
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();

  double get _amount => double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.loan.accountId;
    if (widget.isEmi) {
      final emi = widget.loan.emiAmount;
      _amountController.text = emi == emi.truncateToDouble()
          ? emi.toInt().toString()
          : emi.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];
    final selectedAccount = accounts
        .where((a) => a.id.toString() == _selectedAccountId)
        .firstOrNull;

    final title = widget.isClosure
        ? context.l10n.closeLoan
        : widget.isEmi
            ? context.l10n.payEmi
            : context.l10n.payExtra;

    final buttonLabel = widget.isClosure
        ? context.l10n.confirmClosure
        : context.l10n.confirmPayment;

    return KuberBottomSheet(
      title: title,
      subtitle: widget.loan.name.toUpperCase(),
      actions: AppButton(
        label: buttonLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: _amount > 0 && _selectedAccountId != null
            ? () => _save(context)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount
          Text(
            context.l10n.amountUpper,
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: localeFont(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: localeFont(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
              prefixText: '$symbol ',
              prefixStyle: localeFont(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: cs.onSurfaceVariant,
              ),
              suffixIcon: GestureDetector(
                onTap: () => _openCalculator(context),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Icon(Icons.calculate_outlined,
                      color: cs.onSurfaceVariant),
                ),
              ),
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Account
          Text(
            context.l10n.accountUpper,
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickAccount(context),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedAccount?.name ?? context.l10n.selectAccountTitle,
                      style: localeFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selectedAccount != null
                            ? cs.onSurface
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      color: cs.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Date
          Text(
            context.l10n.dateUpper,
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('MMM d, yyyy').format(_selectedDate),
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Note (for extra / closure)
          if (!widget.isEmi) ...[
            const SizedBox(height: 20),
            Text(
              context.l10n.noteOptional,
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: localeFont(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.addNoteHint,
                hintStyle: localeFont(color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openCalculator(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => KuberCalculator(
        initialValue: _amount,
        onConfirm: (result) {
          setState(() {
            _amountController.text = result == result.truncateToDouble()
                ? result.toInt().toString()
                : result.toStringAsFixed(2);
          });
        },
      ),
    );
  }

  void _pickAccount(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: int.tryParse(_selectedAccountId ?? ''),
        onSelected: (id) {
          setState(() => _selectedAccountId = id.toString());
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save(BuildContext context) {
    final notifier = ref.read(loanListProvider.notifier);
    final note = _noteController.text.trim();

    if (widget.isClosure) {
      notifier.closeLoan(
        loan: widget.loan,
        closureAmount: _amount,
        date: _selectedDate,
        accountId: _selectedAccountId,
      );
    } else if (widget.isEmi) {
      notifier.payEmi(
        loan: widget.loan,
        amount: _amount,
        date: _selectedDate,
        accountId: _selectedAccountId,
      );
    } else {
      notifier.payExtra(
        loan: widget.loan,
        amount: _amount,
        date: _selectedDate,
        accountId: _selectedAccountId,
        note: note.isNotEmpty ? note : null,
      );
    }
    Navigator.pop(context);
  }
}