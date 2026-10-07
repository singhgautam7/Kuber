// =============================================================================
// edit_account_screen.dart
//
// Unified "Edit Account" full-screen. Replaces the two-flow model (the
// AddEditAccountScreen edit form + the EditBalanceSheet bottom sheet) with a
// single screen. Routed at `/accounts/edit` (the ADD flow stays on
// AddEditAccountScreen + AccountForm).
//
// ── DESIGN SYSTEM (non-negotiable) ──────────────────────────────────────────
//   • Colors → colorScheme roles only. No hex.   • Radii → KuberRadius.*.
//   • Depth → borders, never BoxShadow.           • Type → localeFont() (Inter).
//   • Renders in both Obsidian (dark) and Alabaster (light).
//
// ── HERO / ADJUSTMENT MODEL ─────────────────────────────────────────────────
// The hero is the editable money figure that drives a balance-adjustment
// transaction when it changes:
//   • Bank / Cash  → "Current Balance"   (seeded with the live computed balance)
//   • Credit Card  → "Limit Spent"       (seeded with |computed balance|)
// On a real change, Save shows the adjustment confirmation modal first; only
// then is the adjustment transaction created (via
// TransactionListNotifier.addBalanceAdjustment — the same logic that lived in
// EditBalanceSheet). No change ⇒ no adjustment.
//
// Credit cards ALSO get a separate plain "Total Limit" field (writes
// account.creditLimit). Editing Total Limit never creates an adjustment.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_palette.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/icon_color_picker_sheet.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider, settingsProvider;
import '../../transactions/providers/transaction_provider.dart';
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../widgets/adjustment_confirmation_modal.dart';
import '../widgets/credit_billing_cycle_section.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  final Account account;
  const EditAccountScreen({super.key, required this.account});

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _last4Controller;
  late final TextEditingController _valueController; // hero: balance OR spent
  late final TextEditingController _limitController; // credit: total limit

  String? _selectedIcon;
  int? _selectedColor;
  bool _isDefault = false;
  bool _isDisabled = false;
  bool _saving = false;

  // Credit-card billing cycle (credit cards only).
  int? _billGenerationDay;
  int? _paymentDueDay;
  bool _billReminder = false;
  bool _paymentReminder = false;

  // Signed seed used for diff math (matches EditBalanceSheet semantics):
  //   bank/cash → computed balance (positive)
  //   credit    → computed balance (negative; debt)
  double _seedSigned = 0.0;
  bool _seeded = false;

  Account get _a => widget.account;
  bool get _isCredit => _a.isCreditCard;
  bool get _isCash => _a.type == 'cash' && !_a.isCreditCard;
  bool get _showIdentifier => !_isCash;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _a.name);
    _last4Controller = TextEditingController(text: _a.last4Digits ?? '');
    _valueController = TextEditingController()
      ..addListener(() => setState(() {})); // live adjustment indicator
    _limitController = TextEditingController(
      text: _a.creditLimit != null ? _fmtSeed(_a.creditLimit!) : '',
    );
    _selectedIcon = _a.icon ?? IconMapper.kAccountIconKeys.first;
    _selectedColor = _a.colorValue ?? AppColorPalette.kVibrant.first;
    _isDisabled = _a.isDisabled;
    _billGenerationDay = _a.billGenerationDay;
    _paymentDueDay = _a.paymentDueDay;
    _billReminder = _a.billGenerationReminderEnabled;
    _paymentReminder = _a.paymentDueReminderEnabled;

    final defaultId = ref.read(
      settingsProvider.select((s) => s.valueOrNull?.defaultAccountId),
    );
    _isDefault = defaultId == _a.id.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _last4Controller.dispose();
    _valueController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  String _fmtSeed(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// Rounds to paise (2 decimals). The computed balance can carry sub-paise
  /// floating-point residue from summing transactions; comparing that against
  /// the 2-decimal value the user actually sees/types would otherwise report a
  /// phantom fraction-of-a-rupee change on save.
  double _round2(double v) => (v * 100).roundToDouble() / 100;

  /// Seeds the hero field once. Credit shows the limit-spent magnitude
  /// (|balance|); bank/cash shows the signed balance.
  void _seedValueField(double computedBalance) {
    if (_seeded) return;
    _seeded = true;
    _seedSigned = _round2(computedBalance);
    _valueController.text = _fmtSeed(
      _isCredit ? _seedSigned.abs() : _seedSigned,
    );
  }

  /// Signed new hero value, mirroring EditBalanceSheet (_newValue):
  /// credit stores limit-spent as a negative number.
  double? get _typedSigned {
    final raw = double.tryParse(_valueController.text.trim());
    if (raw == null) return null;
    return _isCredit ? -raw : raw;
  }

  double get _diffSigned {
    final v = _typedSigned;
    if (v == null) return 0;
    return _round2(v - _seedSigned);
  }

  bool get _hasAdjustment =>
      _seeded && _typedSigned != null && _diffSigned != 0;

  String _formatCurrency(double v) {
    final symbol = ref.read(currencyProvider).symbol;
    return ref.read(formatterProvider).formatCurrency(v, symbol: symbol);
  }

  // ── SAVE ───────────────────────────────────────────────────────────────
  Future<void> _onSave() async {
    if (_saving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showKuberSnackBar(context, context.l10n.enterAccountName, isError: true);
      return;
    }

    if (_hasAdjustment) {
      final diff = _diffSigned;
      final increased = diff > 0;
      final fromMag = _isCredit ? _seedSigned.abs() : _seedSigned;
      final toMag = _isCredit ? (_typedSigned!).abs() : _typedSigned!;
      final l10n = context.l10n;

      final confirmed = await showAdjustmentConfirmation(
        context,
        valueNoun: _isCredit ? l10n.valueNounLimitSpent : l10n.valueNounBalance,
        valueNounCap: _isCredit
            ? l10n.valueNounLimitSpentCap
            : l10n.valueNounBalanceCap,
        fromText: _formatCurrency(fromMag),
        toText: _formatCurrency(toMag),
        diffText: _formatCurrency(diff.abs()),
        increased: increased,
      );
      if (confirmed != true) return; // cancel → keep typed value

      await _persistAccount(name: name);
      await ref
          .read(transactionListProvider.notifier)
          .addBalanceAdjustment(
            accountId: _a.id,
            diff: diff,
            isCredit: _isCredit,
          );
      _finish();
      return;
    }

    await _persistAccount(name: name);
    _finish();
  }

  Future<void> _persistAccount({required String name}) async {
    setState(() => _saving = true);

    final account = _a
      ..name = name
      ..icon = _selectedIcon
      ..colorValue = _selectedColor
      ..isDisabled = _isDisabled
      ..last4Digits =
          (_showIdentifier && _last4Controller.text.trim().isNotEmpty)
          ? _last4Controller.text.trim()
          : null;
    // Total Limit is a plain field write (no adjustment).
    if (_isCredit) {
      account.creditLimit = double.tryParse(_limitController.text.trim());
      // Billing cycle. Reminder flags follow their day + toggle.
      account
        ..billGenerationDay = _billGenerationDay
        ..paymentDueDay = _paymentDueDay
        ..billGenerationReminderEnabled = _billReminder
        ..paymentDueReminderEnabled = _paymentReminder;
    }
    // type & isCreditCard are intentionally NOT written — read-only forever.
    // initialBalance is NOT written — the adjustment transaction moves balance.

    await ref.read(allAccountsProvider.notifier).add(account);

    final currentDefault = ref.read(
      settingsProvider.select((s) => s.valueOrNull?.defaultAccountId),
    );
    final wasDefault = currentDefault == account.id.toString();
    if (_isDefault && !wasDefault) {
      await ref
          .read(settingsProvider.notifier)
          .setDefaultAccountId(account.id.toString());
    } else if (!_isDefault && wasDefault) {
      await ref.read(settingsProvider.notifier).setDefaultAccountId(null);
    }
  }

  void _finish() {
    if (!mounted) return;
    final rootNav = Navigator.maybeOf(context, rootNavigator: true);
    final hasRootOverlay =
        rootNav != null && Overlay.maybeOf(rootNav.context) != null;
    final message = context.l10n.accountUpdated;

    if (hasRootOverlay) {
      final messengerContext = rootNav.context;
      Navigator.pop(context);
      showKuberSnackBar(messengerContext, message);
    } else {
      showKuberSnackBar(context, message);
      Navigator.pop(context);
    }
  }

  // ── TYPE INFO MODAL ──────────────────────────────────────────────────────
  void _showTypeInfo() {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberShape.extraLarge),
          side: BorderSide(color: cs.outlineVariant),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 20, color: cs.onSurface),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.accountTypeLockedTitle,
                style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.accountTypeLockedBody,
          style: localeFont(
            fontSize: 14,
            height: 1.5,
            color: cs.onSurfaceVariant,
          ),
        ),
        actions: [
          AppButton(
            label: l10n.gotIt,
            type: AppButtonType.primary,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  // ── DELETE (with default-reassignment guard) ─────────────────────────────
  Future<void> _onDelete() async {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final repo = ref.read(accountRepositoryProvider);
    final hasTxns = await repo.hasTransactions(_a.id);
    if (!mounted) return;

    if (hasTxns) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberShape.extraLarge),
            side: BorderSide(color: cs.outlineVariant),
          ),
          title: Text(
            l10n.cannotDeleteAccount,
            style: localeFont(fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.cannotDeleteAccountBody,
            style: localeFont(height: 1.5),
          ),
          actions: [
            AppButton(
              label: l10n.okLabel,
              type: AppButtonType.primary,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    final accounts =
        ref.read(allAccountsProvider).valueOrNull ?? const <Account>[];
    final others = accounts.where((x) => x.id != _a.id).toList();
    if (_isDefault && others.isNotEmpty) {
      final newDefault = await _pickReplacementDefault(others);
      if (newDefault == null) return; // cancelled
      await ref
          .read(settingsProvider.notifier)
          .setDefaultAccountId(newDefault.id.toString());
    } else if (_isDefault) {
      await ref.read(settingsProvider.notifier).setDefaultAccountId(null);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberShape.extraLarge),
          side: BorderSide(color: cs.outlineVariant),
        ),
        title: Text(
          l10n.deleteAccountConfirm,
          style: localeFont(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deleteAccountBody(_a.name),
          style: localeFont(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelLabel, style: localeFont()),
          ),
          AppButton(
            label: l10n.deleteLabel,
            type: AppButtonType.danger,
            onPressed: () {
              ref.read(allAccountsProvider.notifier).delete(_a.id);
              Navigator.pop(ctx); // dialog
              Navigator.pop(context); // screen
            },
          ),
        ],
      ),
    );
  }

  Future<Account?> _pickReplacementDefault(List<Account> options) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return showDialog<Account>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberShape.extraLarge),
          side: BorderSide(color: cs.outlineVariant),
        ),
        title: Text(
          l10n.pickNewDefaultTitle,
          style: localeFont(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.pickNewDefaultBody,
              style: localeFont(height: 1.4, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            for (final acc in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(KuberShape.medium),
                    onTap: () => Navigator.pop(ctx, acc),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(
                          KuberShape.largeIncreased,
                        ),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            acc.icon != null
                                ? IconMapper.fromString(acc.icon!)
                                : Icons.account_balance_rounded,
                            size: 18,
                            color: acc.colorValue != null
                                ? Color(acc.colorValue!)
                                : cs.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              acc.name,
                              style: localeFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelLabel, style: localeFont()),
          ),
        ],
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(accountBalanceProvider(_a.id));
    balanceAsync.whenData(_seedValueField);

    return Scaffold(
      // Board 3.15 edit: close + title + destructive delete in the header.
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        title: context.l10n.editAccount,
        actions: [
          AppIconButton(
            icon: Icons.delete_outline_rounded,
            kind: AppIconButtonKind.danger,
            semanticLabel: context.l10n.deleteAccount,
            onPressed: _onDelete,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: balanceAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        context.l10n.couldntLoadBalance,
                        style: localeFont(color: context.kuberMoney.expense),
                      ),
                    ),
                  ),
                  data: (_) => _buildForm(),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).symbol;
    final iconKey = _selectedIcon ?? IconMapper.kAccountIconKeys.first;
    final colorValue = _selectedColor ?? AppColorPalette.kVibrant.first;
    final field = theme.textTheme.bodyLarge!.copyWith(color: cs.onSurface);

    Widget switchRow({
      required String title,
      required String sub,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) => KuberListRow(
      title: title,
      subtitle: sub,
      subtitleLines: 2,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Live preview ─────────────────────────────────────────────────
        AnimatedBuilder(
          animation: Listenable.merge([_nameController, _valueController]),
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
                            ? _typeName(l10n)
                            : _nameController.text.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '${_typeName(l10n)} · ${sentenceCase(l10n.livePreview)}',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$symbol${_valueController.text.isEmpty ? '0' : _valueController.text}',
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Identity ─────────────────────────────────────────────────────
        KuberFormSection(
          label: l10n.identity,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: field,
              decoration: InputDecoration(
                labelText: sentenceCase(l10n.accountNameLabel),
                hintText: l10n.accountNameHint,
              ),
            ),
            // Type is locked on edit: the chip row shows it, info explains.
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: KuberSpace.sm,
                    runSpacing: KuberSpace.sm,
                    children: [
                      for (final (key, label) in [
                        ('bank', l10n.accountTypeBank),
                        ('cash', l10n.accountTypeCash),
                        ('credit', l10n.accountTypeCreditCard),
                      ])
                        Opacity(
                          opacity: _isTypeKey(key) ? 1 : 0.38,
                          child: KuberChip(
                            label: label,
                            selected: _isTypeKey(key),
                          ),
                        ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.info_outline_rounded,
                  kind: AppIconButtonKind.plain,
                  semanticLabel: l10n.accountTypeLockedTooltip,
                  onPressed: _showTypeInfo,
                ),
              ],
            ),
            if (_showIdentifier)
              TextField(
                controller: _last4Controller,
                keyboardType: TextInputType.number,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: field,
                decoration: InputDecoration(
                  labelText: l10n.accountIdentifierLabel,
                  hintText: l10n.accountIdentifierHint,
                  helperText: l10n.accountIdentifierHelper,
                  helperMaxLines: 2,
                ),
              ),
          ],
        ),

        // ── Balance ──────────────────────────────────────────────────────
        KuberFormSection(
          label: l10n.balanceLabel,
          children: [
            KuberHeroAmountInput(
              label: _isCredit
                  ? l10n.limitSpentLabel
                  : l10n.currentBalanceLabel,
              currencySymbol: symbol,
              controller: _valueController,
              large: false,
              tone: _isCredit ? HeroAmountTone.expense : HeroAmountTone.neutral,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
            ),
            _AdjustmentIndicator(
              hasChange: _hasAdjustment,
              increased: _diffSigned > 0,
              restHelper: l10n.balanceAdjustHelper,
              changedText: _hasAdjustment
                  ? (_diffSigned > 0
                        ? l10n.adjustmentWillBeCredited(
                            _formatCurrency(_diffSigned.abs()),
                          )
                        : l10n.adjustmentWillBeDebited(
                            _formatCurrency(_diffSigned.abs()),
                          ))
                  : '',
            ),
            if (_isCredit)
              TextField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: field,
                decoration: InputDecoration(
                  labelText: l10n.totalLimitLabel,
                  prefixText: '$symbol ',
                  hintText: '0',
                  helperText: l10n.totalLimitHelper,
                  helperMaxLines: 2,
                ),
              ),
          ],
        ),

        // ── Billing cycle (credit only) ──────────────────────────────────
        if (_isCredit) ...[
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

        // ── Appearance ───────────────────────────────────────────────────
        KuberFormSection(
          label: l10n.appearanceCategory,
          children: [
            IconColorPickerRow(
              iconKey: iconKey,
              colorValue: colorValue,
              label: l10n.iconAndColour,
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
              ),
            ),
          ],
        ),

        // ── Default + Disable as one group ───────────────────────────────
        const SizedBox(height: KuberSpace.xl),
        KuberGroup(
          children: [
            switchRow(
              title: l10n.makeDefaultAccount,
              sub: l10n.makeDefaultAccountSub,
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
            ),
            switchRow(
              title: _isDisabled
                  ? l10n.accountDisabledToggle
                  : l10n.disableAccountToggle,
              sub: _isDisabled
                  ? l10n.accountDisabledHelper
                  : l10n.disableAccountHelper,
              value: _isDisabled,
              onChanged: (v) => setState(() => _isDisabled = v),
            ),
          ],
        ),
      ],
    );
  }

  bool _isTypeKey(String key) => switch (key) {
    'credit' => _isCredit,
    'cash' => _isCash,
    _ => !_isCredit && !_isCash,
  };

  String _typeName(AppLocalizations l10n) {
    if (_isCredit) return l10n.accountTypeCreditCard;
    if (_isCash) return l10n.accountTypeCash;
    return l10n.accountTypeBank;
  }

  Widget _buildBottomBar() {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final navInset = MediaQuery.of(
      context,
    ).viewPadding.bottom; // 3-button inset
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + navInset),
        child: AppButton(
          label: l10n.saveChanges,
          type: AppButtonType.primary,
          fullWidth: true,
          isLoading: _saving,
          onPressed: _onSave,
        ),
      ),
    );
  }
}

// =============================================================================
// Live adjustment indicator under the hero.
//   • No change  → muted resting helper text.
//   • Changed    → tinted chip with the localized credited / debited sentence
//                  (green up / red down).
// =============================================================================
class _AdjustmentIndicator extends StatelessWidget {
  final bool hasChange;
  final bool increased;
  final String changedText;
  final String restHelper;
  const _AdjustmentIndicator({
    required this.hasChange,
    required this.increased,
    required this.changedText,
    required this.restHelper,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!hasChange) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.sync_alt_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                restHelper,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    final m = context.kuberMoney;
    final bg = increased ? m.incomeContainer : m.expenseContainer;
    final tone = increased ? m.onIncomeContainer : m.onExpenseContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: KuberShape.largeR),
      child: Row(
        children: [
          Icon(
            increased
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 15,
            color: tone,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              changedText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: tone),
            ),
          ),
        ],
      ),
    );
  }
}
