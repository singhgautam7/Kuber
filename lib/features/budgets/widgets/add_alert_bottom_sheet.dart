import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/budget.dart';

class AddAlertBottomSheet extends ConsumerStatefulWidget {
  final double budgetAmount;
  final List<BudgetAlert> existingAlerts;
  final Function(BudgetAlert) onAdd;

  const AddAlertBottomSheet({
    super.key,
    required this.budgetAmount,
    required this.existingAlerts,
    required this.onAdd,
  });

  @override
  ConsumerState<AddAlertBottomSheet> createState() => _AddAlertBottomSheetState();
}

class _AddAlertBottomSheetState extends ConsumerState<AddAlertBottomSheet> {
  BudgetAlertType _type = BudgetAlertType.percentage;
  late final TextEditingController _controller;
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // The provided code edit seems to be for a different widget (AddEditBudgetScreen)
    // as it references `widget.existingBudget` and `_amountController` which are not
    // part of AddAlertBottomSheet.
    // Applying only the line that is relevant and syntactically correct for this widget.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _description {
    final value = double.tryParse(_controller.text) ?? 0;
    if (_type == BudgetAlertType.percentage) {
      return 'Alert me when spending reaches ${ref.watch(formatterProvider).formatPercentage(value)} of my monthly budget.';
    } else {
      return 'Alert me when spending reaches ${ref.watch(formatterProvider).formatCurrency(value)} of my monthly budget.';
    }
  }

  String? get _errorText {
    if (_controller.text.isEmpty) return 'Enter a valid value';
    final value = double.tryParse(_controller.text);
    if (value == null || value <= 0) return 'Enter a valid value';

    if (_type == BudgetAlertType.percentage) {
      if (value > 100) return 'Percentage cannot exceed 100%';
    } else {
      if (value > widget.budgetAmount) return 'Amount cannot exceed budget limit';
    }

    // Check for duplicates
    final isDuplicate = widget.existingAlerts.any((a) => a.type == _type && a.value == value);
    if (isDuplicate) return 'An alert for this value already exists';

    return null;
  }

  bool get _isValid => _errorText == null;

  void _submit() {
    if (!_isValid) return;
    
    final alert = BudgetAlert()
      ..type = _type
      ..value = double.parse(_controller.text)
      ..isNotificationEnabled = _isNotificationEnabled;
    
    widget.onAdd(alert);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, viewPadding > 0 ? viewPadding + 16 : 32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Alert',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Alert type toggle
          Text(
            'SELECT ALERT TYPE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildToggleButton(
                  'Percentage (%)',
                  _type == BudgetAlertType.percentage,
                  () => setState(() => _type = BudgetAlertType.percentage),
                ),
                _buildToggleButton(
                  'Fixed Amount (${ref.watch(currencyProvider).symbol})',
                  _type == BudgetAlertType.amount,
                  () => setState(() => _type = BudgetAlertType.amount),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: "0",
                        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _type == BudgetAlertType.percentage ? '%' : ref.watch(currencyProvider).symbol,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 20, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_outlined, size: 24, color: cs.onSurface),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Push Notification',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: _isNotificationEnabled,
                  onChanged: (v) => setState(() => _isNotificationEnabled = v),
                  activeThumbColor: cs.primary,
                  activeTrackColor: cs.primary.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error Message Display
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _errorText != null && _controller.text.isNotEmpty
                ? Padding(
                    key: ValueKey(_errorText),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        _errorText!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.error,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _isValid ? _submit : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ADD ALERT',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
