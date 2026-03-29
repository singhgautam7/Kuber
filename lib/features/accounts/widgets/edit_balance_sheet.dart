import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/account.dart';

class EditBalanceSheet extends ConsumerStatefulWidget {
  final Account account;
  final double currentValue;
  final bool isCredit;

  const EditBalanceSheet({
    super.key,
    required this.account,
    required this.currentValue,
    required this.isCredit,
  });

  @override
  ConsumerState<EditBalanceSheet> createState() => _EditBalanceSheetState();
}

class _EditBalanceSheetState extends ConsumerState<EditBalanceSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? get _newValue {
    final raw = double.tryParse(_controller.text);
    if (raw == null) return null;
    return widget.isCredit ? -raw : raw;
  }

  double get _diff => (_newValue ?? widget.currentValue) - widget.currentValue;

  bool get _hasValidChange =>
      _newValue != null && _diff != 0 && _controller.text.isNotEmpty;

  Future<void> _save() async {
    if (!_hasValidChange || _saving) return;
    setState(() => _saving = true);

    final diff = _diff;
    final transactionDiff = widget.isCredit ? -diff : diff;
    final isPositive = transactionDiff > 0;

    final adjustment = Transaction()
      ..name = widget.isCredit ? 'Limit Spent Adjustment' : 'Balance Adjustment'
      ..amount = transactionDiff.abs()
      ..type = isPositive ? 'income' : 'expense'
      ..accountId = widget.account.id.toString()
      ..categoryId = ''
      ..isBalanceAdjustment = true
      ..isRecurring = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..nameLower = widget.isCredit
          ? 'limit spent adjustment'
          : 'balance adjustment';

    await ref.read(transactionListProvider.notifier).add(adjustment);

    if (mounted) {
      Navigator.pop(context);
      showKuberSnackBar(
        context,
        widget.isCredit
            ? 'Limit spent updated successfully'
            : 'Balance updated successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final symbol = ref.watch(currencyProvider).symbol;
    final label = widget.isCredit ? 'Edit Limit Spent' : 'Edit Balance';
    final currentLabel =
        widget.isCredit ? 'CURRENT LIMIT SPENT' : 'CURRENT BALANCE';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + KuberSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header row
          Row(
            children: [
              CategoryIcon.square(
                icon: resolveAccountIcon(widget.account),
                rawColor: resolveAccountColor(widget.account),
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHigh,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Current value display
          Text(
            currentLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatter.formatCurrency(widget.currentValue),
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 24),

          // New value input
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            autofocus: true,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              labelText: widget.isCredit ? 'New Limit Spent' : 'New Balance',
              prefixText: widget.isCredit ? '-$symbol ' : '$symbol ',
              prefixStyle: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: widget.isCredit ? cs.error : cs.onSurfaceVariant,
              ),
              labelStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
          ),

          // Preview text
          if (_hasValidChange) ...[
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '${_diff > 0 ? '+' : '-'}${formatter.formatCurrency(_diff.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _diff > 0 ? cs.tertiary : cs.error,
                    ),
                  ),
                  const TextSpan(text: ' adjustment will be recorded as a transaction (analytics won\'t be affected)'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Save button
          AppButton(
            label: 'Save',
            type: AppButtonType.primary,
            fullWidth: true,
            isLoading: _saving,
            onPressed: _hasValidChange ? _save : null,
          ),
        ],
      ),
    );
  }
}
