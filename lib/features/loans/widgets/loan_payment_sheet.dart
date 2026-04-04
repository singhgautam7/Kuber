import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider;
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
  double _amount = 0;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.loan.accountId;
    if (widget.isEmi) {
      _amount = widget.loan.emiAmount;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final symbol = ref.watch(currencyProvider).symbol;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];
    final selectedAccount = accounts
        .where((a) => a.id.toString() == _selectedAccountId)
        .firstOrNull;

    final title = widget.isClosure
        ? 'Close Loan'
        : widget.isEmi
            ? 'Pay EMI'
            : 'Pay Extra';

    final buttonLabel = widget.isClosure
        ? 'CONFIRM CLOSURE'
        : 'CONFIRM PAYMENT';

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
            'AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openCalculator(context),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Text(
                _amount > 0
                    ? '$symbol ${fmt.formatCurrency(_amount)}'
                    : 'Tap to enter amount',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _amount > 0 ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Account
          Text(
            'ACCOUNT',
            style: GoogleFonts.inter(
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
                      selectedAccount?.name ?? 'Select account',
                      style: GoogleFonts.inter(
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
            'DATE',
            style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
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
              'NOTE (OPTIONAL)',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Add a note...',
                hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberCalculator(
        initialValue: _amount,
        onConfirm: (result) => setState(() => _amount = result),
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
