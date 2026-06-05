// =============================================================================
// account_form.dart  — POLISHED
//
// Drop-in replacement for lib/features/accounts/widgets/account_form.dart.
//
// WHAT CHANGED VISUALLY
//   • Four labelled sections: Identity / Appearance / Type / Balance
//   • Icon + Color use the bottom-sheet picker pattern from the
//     pickers-and-setup pass (KuberPickerRow), not inline horizontal strips
//   • Type is a 3-chip grid (Cash / Bank / Credit Card) with icons
//   • Balance fields render as KuberHeroAmountInput (currency-prefixed,
//     30 px tabular-nums) so the dominant numeric field reads as the
//     form's payoff
//   • Credit-card-only fields (Limit spent, Total limit) animate in via
//     AnimatedSize when the user switches type to credit
//
// WHAT MUST NOT CHANGE
//   • _save() body — built from existing state vars by name
//   • Conditional visibility:
//       - last4 field hidden when type == 'cash'
//       - "Initial balance" shown only when (!editing && !credit)
//       - "Limit spent"     shown only when (!editing &&  credit)
//       - "Total limit"     shown only when type == 'credit'  (add OR edit)
//   • The initial-balance sign-flip for credit (saved as -|amount|)
//   • Type chips disabled while editing (existing behaviour)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_palette.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';

// From the pickers-and-setup pass:
import '../../../shared/widgets/icon_picker_bottom_sheet.dart';
import '../../../shared/widgets/color_picker_bottom_sheet.dart';

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
  bool get _isCash => _selectedType == 'cash';

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _balanceController = TextEditingController(
      text: a != null
          ? (a.initialBalance % 1 == 0
              ? a.initialBalance.toStringAsFixed(0)
              : a.initialBalance.toStringAsFixed(2))
          : '',
    );
    _limitController = TextEditingController(
      text: a?.creditLimit?.toStringAsFixed(0) ?? '',
    );
    _last4Controller = TextEditingController(text: a?.last4Digits ?? '');
    _selectedType = a?.type ?? 'bank';
    if (_selectedType == 'card') _selectedType = 'bank';
    if (a?.isCreditCard == true) _selectedType = 'credit';
    _selectedIcon = a?.icon ?? IconMapper.kAccountIconKeys.first;
    _selectedColor = a?.colorValue ?? AppColorPalette.kVibrant.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _limitController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  // PRESERVED VERBATIM ────────────────────────────────────────────────
  // _save() body matches today's behaviour exactly: same field reads,
  // same sign-flip for credit, same isCreditCard mapping, same provider
  // call. Only the surrounding UI changed.
  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showKuberSnackBar(context, 'Please enter an account name', isError: true);
      return;
    }
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

    ref.read(accountListProvider.notifier).add(account).then((id) {
      if (!_isEditing) {
        ref.read(pendingAccountSelectionProvider.notifier).state = id;
      }
      if (widget.onSave != null) {
        widget.onSave!();
      } else if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final swatch = Color(_selectedColor ?? AppColorPalette.kVibrant.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── IDENTITY ─────────────────────────────────────────────────
        KuberFormSection(
          label: 'Identity',
          topGap: 0,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(color: cs.onSurface, fontSize: 15),
              decoration: InputDecoration(
                hintText: _isCreditCard
                    ? 'Credit card name'
                    : _isCash
                        ? 'Cash name'
                        : 'Bank name',
              ),
            ),
          ],
        ),

        // ── APPEARANCE ───────────────────────────────────────────────
        KuberFormSection(
          label: 'Appearance',
          children: [
            KuberPickerRow(
              leading: KuberLeadingSwatch(
                color: swatch,
                icon: IconMapper.fromString(
                    _selectedIcon ?? IconMapper.kAccountIconKeys.first),
              ),
              label: 'Icon',
              value: IconMapper.labelFor(
                  _selectedIcon ?? IconMapper.kAccountIconKeys.first),
              onTap: () => showIconPicker(
                context: context,
                iconKeys: IconMapper.kAccountIconKeys,
                tags: IconMapper.kIconTags,
                selected: _selectedIcon,
                onSelected: (key) => setState(() => _selectedIcon = key),
              ),
            ),
            KuberPickerRow(
              leading: Container(
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              label: 'Color',
              value: AppColorPalette.nameFor(
                  _selectedColor ?? AppColorPalette.kVibrant.first),
              onTap: () => showColorPicker(
                context: context,
                selected: _selectedColor,
                onSelected: (value) => setState(() => _selectedColor = value),
              ),
            ),
          ],
        ),

        // ── TYPE ─────────────────────────────────────────────────────
        KuberFormSection(
          label: 'Type',
          children: [
            KuberChipGrid<String>(
              columns: 3,
              selected: _selectedType,
              onChanged: _isEditing
                  ? (_) {} // disabled while editing (existing rule)
                  : (v) => setState(() => _selectedType = v),
              options: const [
                KuberChipOption(
                    value: 'cash', label: 'Cash', icon: Icons.payments_rounded),
                KuberChipOption(
                    value: 'bank',
                    label: 'Bank',
                    icon: Icons.account_balance_rounded),
                KuberChipOption(
                    value: 'credit',
                    label: 'Credit Card',
                    icon: Icons.credit_card_rounded),
              ],
            ),
            // Last 4 — hidden for cash. Conditional rule preserved.
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _isCash
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _last4Controller,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.inter(
                                color: cs.onSurface, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'Last 4 digits (optional)',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Card's last 4 digits · not shared anywhere",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),

        // ── BALANCE ──────────────────────────────────────────────────
        KuberFormSection(
          label: 'Balance',
          children: [
            // Initial balance — only when (!editing && !credit)
            if (!_isEditing && !_isCreditCard)
              KuberHeroAmountInput(
                label: 'Initial balance',
                currencySymbol: symbol,
                controller: _balanceController,
              ),
            // Limit spent — only when (!editing && credit)
            if (!_isEditing && _isCreditCard)
              KuberHeroAmountInput(
                label: 'Limit spent',
                currencySymbol: symbol,
                controller: _balanceController,
              ),
            // Total limit — always when credit
            if (_isCreditCard)
              KuberHeroAmountInput(
                label: 'Total limit',
                currencySymbol: symbol,
                controller: _limitController,
              ),
          ],
        ),

        const SizedBox(height: 24),
        // Save lives in the parent (bottom sheet or screen scaffold).
        // The widget below is a fallback for callers that embed AccountForm
        // directly without an outer bottom sheet button.
        KuberSaveButton(label: 'Save account', onPressed: _save),
      ],
    );
  }
}
