import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/ledger.dart';
import '../providers/ledger_provider.dart';

class AddPaymentSheet extends ConsumerStatefulWidget {
  final Ledger ledger;

  const AddPaymentSheet({super.key, required this.ledger});

  @override
  ConsumerState<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddPaymentSheet> {
  final _amountController = TextEditingController();
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.ledger.accountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
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

    return KuberBottomSheet(
      title: 'Record Payment',
      subtitle: widget.ledger.personName.toUpperCase(),
      actions: AppButton(
        label: 'RECORD PAYMENT',
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
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
              prefixText: '$symbol ',
              prefixStyle: GoogleFonts.inter(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: cs.onSurfaceVariant),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
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
    ref.read(ledgerListProvider.notifier).addPayment(
          ledger: widget.ledger,
          amount: _amount,
          accountId: _selectedAccountId!,
          date: _selectedDate,
        );
    Navigator.pop(context);
  }
}
