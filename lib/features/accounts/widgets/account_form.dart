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

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/utils/locale_font.dart' show sentenceCase;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_palette.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';

// From the pickers-and-setup pass:
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/icon_color_picker_sheet.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'credit_billing_cycle_section.dart';

class AccountForm extends ConsumerStatefulWidget {
  final Account? account;
  final VoidCallback? onSave;

  /// Full-screen use (Add Account route): the fields scroll and the save
  /// button is pinned under them (board 3.15). Embedded use keeps the save
  /// button at the end of the column.
  final bool pinnedSave;
  const AccountForm({
    super.key,
    this.account,
    this.onSave,
    this.pinnedSave = false,
  });

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

  // Credit-card billing cycle (only meaningful when type == credit).
  int? _billGenerationDay;
  int? _paymentDueDay;
  bool _billReminder = false;
  bool _paymentReminder = false;

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
    _billGenerationDay = a?.billGenerationDay;
    _paymentDueDay = a?.paymentDueDay;
    _billReminder = a?.billGenerationReminderEnabled ?? false;
    _paymentReminder = a?.paymentDueReminderEnabled ?? false;
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
      showKuberSnackBar(context, context.l10n.enterAccountName, isError: true);
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
      ..creditLimit = _isCreditCard
          ? double.tryParse(_limitController.text)
          : null
      ..last4Digits = _last4Controller.text.isNotEmpty
          ? _last4Controller.text
          : null
      // Credit-card billing cycle — cleared when the account is not a card.
      ..billGenerationDay = _isCreditCard ? _billGenerationDay : null
      ..paymentDueDay = _isCreditCard ? _paymentDueDay : null
      ..billGenerationReminderEnabled = _isCreditCard && _billReminder
      ..paymentDueReminderEnabled = _isCreditCard && _paymentReminder;

    ref.read(allAccountsProvider.notifier).add(account).then((id) {
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final iconKey = _selectedIcon ?? IconMapper.kAccountIconKeys.first;
    final colorValue = _selectedColor ?? AppColorPalette.kVibrant.first;
    final typeLabel = _isCreditCard
        ? context.l10n.creditCardLabel
        : _isCash
        ? context.l10n.cashLabel
        : context.l10n.bankLabel;

    // Board 3.15 add / edit: live preview, Identity, Balance, Appearance.
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── LIVE PREVIEW ─────────────────────────────────────────────
        AnimatedBuilder(
          animation: Listenable.merge([_nameController, _balanceController]),
          builder: (context, _) => KuberCard(
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: KuberLeadingSwatch(
                    color: Color(colorValue),
                    icon: IconMapper.fromString(iconKey),
                  ),
                ),
                const SizedBox(width: KuberSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.trim().isEmpty
                            ? typeLabel
                            : _nameController.text.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '$typeLabel · ${sentenceCase(context.l10n.livePreview)}',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$symbol${_balanceController.text.isEmpty ? '0' : _balanceController.text}',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── IDENTITY ─────────────────────────────────────────────────
        KuberFormSection(
          label: context.l10n.identity,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: theme.textTheme.bodyLarge!.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: sentenceCase(context.l10n.accountNameLabel),
                hintText: _isCreditCard
                    ? context.l10n.creditCardName
                    : _isCash
                    ? context.l10n.cashName
                    : context.l10n.bankName,
              ),
            ),
            // Type as filter chips (disabled while editing, existing rule).
            Wrap(
              spacing: KuberSpace.sm,
              runSpacing: KuberSpace.sm,
              children: [
                for (final (value, label) in [
                  ('bank', context.l10n.bankLabel),
                  ('cash', context.l10n.cashLabel),
                  ('credit', context.l10n.creditCardLabel),
                ])
                  Opacity(
                    opacity: _isEditing && _selectedType != value ? 0.38 : 1,
                    child: KuberChip(
                      label: label,
                      selected: _selectedType == value,
                      onTap: _isEditing
                          ? null
                          : () => setState(() => _selectedType = value),
                    ),
                  ),
              ],
            ),
            // Last 4: hidden for cash (existing rule).
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _isCash
                  ? const SizedBox.shrink()
                  : TextField(
                      controller: _last4Controller,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.last4DigitsHint,
                        helperText: context.l10n.cardLast4Note,
                        helperMaxLines: 2,
                        counterText: '',
                      ),
                    ),
            ),
          ],
        ),

        // ── BALANCE ──────────────────────────────────────────────────
        if (!_isEditing || _isCreditCard)
          KuberFormSection(
            label: context.l10n.balanceLabel,
            children: [
              // Initial balance: only when (!editing && !credit)
              if (!_isEditing && !_isCreditCard)
                KuberHeroAmountInput(
                  label: context.l10n.initialBalance,
                  currencySymbol: symbol,
                  controller: _balanceController,
                  large: false,
                ),
              // Credit card: limit spent (add only) + total limit, side by side.
              if (_isCreditCard)
                Row(
                  children: [
                    if (!_isEditing) ...[
                      Expanded(
                        child: KuberHeroAmountInput(
                          label: context.l10n.limitSpentField,
                          currencySymbol: symbol,
                          controller: _balanceController,
                          large: false,
                        ),
                      ),
                      const SizedBox(width: KuberSpace.md),
                    ],
                    Expanded(
                      child: KuberHeroAmountInput(
                        label: context.l10n.totalLimitField,
                        currencySymbol: symbol,
                        controller: _limitController,
                        large: false,
                      ),
                    ),
                  ],
                ),
            ],
          ),

        // ── BILLING CYCLE (credit card only) ─────────────────────────
        if (_isCreditCard) ...[
          const SizedBox(height: KuberSpace.xl),
          CreditBillingCycleSection(
            billDay: _billGenerationDay,
            dueDay: _paymentDueDay,
            billReminder: _billReminder,
            dueReminder: _paymentReminder,
            onBillDayChanged: (v) => setState(() => _billGenerationDay = v),
            onDueDayChanged: (v) => setState(() => _paymentDueDay = v),
            onBillReminderChanged: (v) => setState(() => _billReminder = v),
            onDueReminderChanged: (v) => setState(() => _paymentReminder = v),
          ),
        ],

        // ── APPEARANCE ───────────────────────────────────────────────
        KuberFormSection(
          label: context.l10n.appearanceCategory,
          children: [
            IconColorPickerRow(
              iconKey: iconKey,
              colorValue: colorValue,
              label: context.l10n.iconAndColour,
              onTap: () => showIconColorPicker(
                context: context,
                iconKeys: IconMapper.kAccountIconKeys,
                tags: IconMapper.kIconTags,
                iconKey: iconKey,
                colorValue: colorValue,
                onDone: (icon, color) => setState(() {
                  _selectedIcon = icon;
                  _selectedColor = color;
                }),
              ).unfocusOnComplete(context),
            ),
          ],
        ),

        const SizedBox(height: KuberSpace.xl),
        if (!widget.pinnedSave)
          AppButton(
            label: context.l10n.saveAccount,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: _save,
          ),
      ],
    );
    if (!widget.pinnedSave) return fields;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: fields,
          ),
        ),
        KuberSaveButton(label: context.l10n.saveAccount, onPressed: _save),
      ],
    );
  }
}
