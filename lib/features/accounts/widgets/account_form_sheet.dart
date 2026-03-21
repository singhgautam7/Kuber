import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../data/account.dart';
import '../providers/account_provider.dart';

const _accountIcons = [
  'account_balance',
  'credit_card',
  'payments',
  'wallet',
  'savings',
  'account_balance_wallet',
  'attach_money',
  'local_atm',
  'home',
  'work',
  'school',
  'flight',
  'store',
  'shopping_bag',
  'restaurant',
  'directions_car',
  'favorite',
  'movie',
  'trending_up',
  'receipt_long',
];

const _accountColors = [
  0xFF5C6BC0, // indigo
  0xFF42A5F5, // blue
  0xFF26A69A, // teal
  0xFF66BB6A, // green
  0xFFFFCA28, // amber
  0xFFFF7043, // deep orange
  0xFFEF5350, // red
  0xFFAB47BC, // purple
  0xFFEC407A, // pink
  0xFF78909C, // blue grey
  0xFF8D6E63, // brown
  0xFF29B6F6, // light blue
];

class AccountFormSheet extends ConsumerStatefulWidget {
  final Account? account;

  const AccountFormSheet({super.key, this.account});

  @override
  ConsumerState<AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<AccountFormSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _limitController;
  late final TextEditingController _last4Controller;
  late String _selectedType;
  String? _selectedIcon;
  int? _selectedColor;

  bool get _isEditing => widget.account != null;
  bool get _isCreditCard => _selectedType == 'credit';

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _balanceController = TextEditingController(
      text: a != null ? a.initialBalance.toStringAsFixed(2) : '',
    );
    _limitController = TextEditingController(
      text: a?.creditLimit?.toStringAsFixed(0) ?? '',
    );
    _last4Controller = TextEditingController(text: a?.last4Digits ?? '');
    _selectedType = a?.type ?? 'cash';
    // Normalize old 'card'/'upi' types for editing
    if (_selectedType == 'card' || _selectedType == 'upi') {
      _selectedType = 'bank';
    }
    // If editing a credit card, show 'credit' type
    if (a?.isCreditCard == true) {
      _selectedType = 'credit';
    }
    _selectedIcon = a?.icon ?? _accountIcons[0];
    _selectedColor = a?.colorValue ?? _accountColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _limitController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final account = widget.account ?? Account();
    account
      ..name = name
      ..type = _selectedType == 'credit' ? 'bank' : _selectedType
      ..isCreditCard = _isCreditCard && _selectedType != 'cash'
      ..icon = _selectedIcon
      ..colorValue = _selectedColor
      ..initialBalance = double.tryParse(_balanceController.text) ?? 0.0
      ..creditLimit =
          _isCreditCard ? double.tryParse(_limitController.text) : null
      ..last4Digits = _last4Controller.text.isNotEmpty
          ? _last4Controller.text
          : null;

    ref.read(accountListProvider.notifier).add(account);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: KuberColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _isEditing ? 'Edit Account' : 'Add Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: KuberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextField(
              controller: _nameController,
              style:
                  GoogleFonts.plusJakartaSans(color: KuberColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Account Name',
                labelStyle: GoogleFonts.plusJakartaSans(
                    color: KuberColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),

            // Icon picker
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Icon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KuberColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _accountIcons.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final iconName = _accountIcons[i];
                  final isSelected = _selectedIcon == iconName;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? KuberColors.primary.withValues(alpha: 0.15)
                            : KuberColors.surfaceElement,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: KuberColors.primary, width: 2)
                            : null,
                      ),
                      child: Icon(
                        IconMapper.fromString(iconName),
                        size: 22,
                        color: isSelected
                            ? KuberColors.primary
                            : KuberColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Color picker
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Color',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KuberColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _accountColors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final colorVal = _accountColors[i];
                  final isSelected = _selectedColor == colorVal;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorVal),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      Color(colorVal).withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Type selector
            Row(
              children: [
                _buildTypeChip('cash', Icons.payments_rounded, 'Cash'),
                const SizedBox(width: 8),
                _buildTypeChip('bank', Icons.account_balance_rounded, 'Bank'),
                const SizedBox(width: 8),
                _buildTypeChip(
                    'credit', Icons.credit_card_rounded, 'Credit Card'),
              ],
            ),
            const SizedBox(height: 16),

            // Last 4 digits (bank/credit only)
            if (_selectedType == 'bank' || _selectedType == 'credit')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: _last4Controller,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Last 4 digits',
                    helperText:
                        'Just to help you identify your account — stored only on your device',
                    helperMaxLines: 2,
                    labelStyle: GoogleFonts.plusJakartaSans(
                        color: KuberColors.textSecondary),
                    helperStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: KuberColors.textMuted,
                    ),
                  ),
                ),
              ),

            // Balance / Credit fields
            if (!_isCreditCard)
              TextField(
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: GoogleFonts.plusJakartaSans(
                    color: KuberColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Initial Balance',
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary),
                  labelStyle: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary),
                ),
              )
            else ...[
              TextField(
                controller: _balanceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: GoogleFonts.plusJakartaSans(
                    color: KuberColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Credit Utilized',
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary),
                  labelStyle: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.plusJakartaSans(
                    color: KuberColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Total Limit',
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary),
                  labelStyle: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: KuberColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Save Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, IconData icon, String label) {
    final selected = _selectedType == type;
    final disabled = _isEditing;
    return Expanded(
      child: GestureDetector(
        onTap: disabled
            ? null
            : () => setState(() {
                  _selectedType = type;
                  if (type == 'cash') _last4Controller.clear();
                }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (disabled
                    ? KuberColors.primary.withValues(alpha: 0.08)
                    : KuberColors.primary.withValues(alpha: 0.15))
                : KuberColors.surfaceElement,
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
                    color: KuberColors.primary
                        .withValues(alpha: disabled ? 0.2 : 0.4))
                : null,
          ),
          child: Opacity(
            opacity: disabled && !selected ? 0.4 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? KuberColors.primary
                      : KuberColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? KuberColors.primary
                        : KuberColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
