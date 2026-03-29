import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_palette.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../../../shared/widgets/app_button.dart';

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

const _accountColors = AppColorPalette.colors;

class AccountForm extends ConsumerStatefulWidget {
  final Account? account;
  final VoidCallback? onSave;

  const AccountForm({super.key, this.account, this.onSave});

  @override
  ConsumerState<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountForm> {
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
      text: a != null
          ? (a.initialBalance % 1 == 0 ? a.initialBalance.toStringAsFixed(0) : a.initialBalance.toStringAsFixed(2))
          : '',
    );
    _limitController = TextEditingController(
      text: a?.creditLimit?.toStringAsFixed(0) ?? '',
    );
    _last4Controller = TextEditingController(text: a?.last4Digits ?? '');
    _selectedType = a?.type ?? 'bank';
    // Normalize old 'card'/'upi'/'cash' types for editing
    if (_selectedType == 'card' || _selectedType == 'upi' || _selectedType == 'cash') {
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
      ..isCreditCard = _isCreditCard
      ..icon = _selectedIcon
      ..colorValue = _selectedColor
      ..initialBalance = _isEditing
          ? account.initialBalance
          : _isCreditCard
              ? -(double.tryParse(_balanceController.text) ?? 0.0).abs()
              : (double.tryParse(_balanceController.text) ?? 0.0)
      ..creditLimit =
          _isCreditCard ? double.tryParse(_limitController.text) : null
      ..last4Digits = _last4Controller.text.isNotEmpty
          ? _last4Controller.text
          : null;

    ref.read(accountListProvider.notifier).add(account);
    if (widget.onSave != null) {
      widget.onSave!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        TextField(
          controller: _nameController,
          style: GoogleFonts.inter(color: cs.onSurface),
          decoration: InputDecoration(
            labelText: _selectedType == 'credit' ? 'Credit Card Name' : 'Cash or Bank Name',
            labelStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 20),

        // Icon picker
        Text(
          'Icon',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
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
                        ? cs.primary.withValues(alpha: 0.15)
                        : cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: cs.primary, width: 2)
                        : null,
                  ),
                  child: Icon(
                    IconMapper.fromString(iconName),
                    size: 22,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Color picker
        Text(
          'Color',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
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
                              color: Color(colorVal).withValues(alpha: 0.5),
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
            _buildTypeChip('bank', Icons.account_balance_rounded, 'Bank / Cash'),
            const SizedBox(width: 8),
            _buildTypeChip('credit', Icons.credit_card_rounded, 'Credit Card'),
          ],
        ),
        const SizedBox(height: 16),

        // Last 4 digits
        if (_selectedType == 'bank' || _selectedType == 'credit')
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: _last4Controller,
              maxLength: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.inter(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: 'Last 4 digits (Optional)',
                helperText:
                    'Not shared anywhere',
                helperMaxLines: 2,
                labelStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
                helperStyle: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),

        // Balance / Credit fields — only shown when creating, not editing
        if (!_isEditing && !_isCreditCard)
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Initial Balance',
              prefixText: '$symbol ',
              prefixStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
              labelStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
            ),
          )
        else if (!_isEditing && _isCreditCard) ...[
          TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Limit Spent',
              prefixText: '$symbol ',
              prefixStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
              labelStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Total Limit — always shown for credit cards (both add & edit)
        if (_isCreditCard)
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Total Limit',
              prefixText: '$symbol ',
              prefixStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
              labelStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 24),

        AppButton(
          label: 'Save Account',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _save,
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, IconData icon, String label) {
    final cs = Theme.of(context).colorScheme;
    final selected = _selectedType == type;
    final disabled = _isEditing;
    return Expanded(
      child: GestureDetector(
        onTap: disabled
            ? null
            : () => setState(() {
                  _selectedType = type;
                }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (disabled
                    ? cs.primary.withValues(alpha: 0.08)
                    : cs.primary.withValues(alpha: 0.15))
                : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: selected
                ? Border.all(
                    color: cs.primary
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
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? cs.primary : cs.onSurfaceVariant,
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
