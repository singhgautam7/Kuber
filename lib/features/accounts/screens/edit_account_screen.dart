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
import '../../../shared/widgets/icon_picker_bottom_sheet.dart';
import '../../../shared/widgets/color_picker_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider, settingsProvider;
import '../../transactions/providers/transaction_provider.dart';
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../widgets/adjustment_confirmation_modal.dart';

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

  /// Seeds the hero field once. Credit shows the limit-spent magnitude
  /// (|balance|); bank/cash shows the signed balance.
  void _seedValueField(double computedBalance) {
    if (_seeded) return;
    _seeded = true;
    _seedSigned = computedBalance;
    _valueController.text =
        _fmtSeed(_isCredit ? computedBalance.abs() : computedBalance);
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
    return v - _seedSigned;
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
        valueNounCap:
            _isCredit ? l10n.valueNounLimitSpentCap : l10n.valueNounBalanceCap,
        fromText: _formatCurrency(fromMag),
        toText: _formatCurrency(toMag),
        diffText: _formatCurrency(diff.abs()),
        increased: increased,
      );
      if (confirmed != true) return; // cancel → keep typed value

      await _persistAccount(name: name);
      await ref.read(transactionListProvider.notifier).addBalanceAdjustment(
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
    final messengerContext =
        Navigator.of(context, rootNavigator: true).context;
    final message = context.l10n.accountUpdated;
    Navigator.pop(context);
    showKuberSnackBar(messengerContext, message);
  }

  // ── TYPE INFO MODAL ──────────────────────────────────────────────────────
  void _showTypeInfo() {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: cs.outline),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 20, color: cs.onSurface),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l10n.accountTypeLockedTitle,
                  style: localeFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface)),
            ),
          ],
        ),
        content: Text(l10n.accountTypeLockedBody,
            style: localeFont(
                fontSize: 14, height: 1.5, color: cs.onSurfaceVariant)),
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
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            side: BorderSide(color: cs.outline),
          ),
          title: Text(l10n.cannotDeleteAccount,
              style: localeFont(fontWeight: FontWeight.bold)),
          content: Text(l10n.cannotDeleteAccountBody,
              style: localeFont(height: 1.5)),
          actions: [
            AppButton(
                label: l10n.okLabel,
                type: AppButtonType.primary,
                onPressed: () => Navigator.pop(ctx)),
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
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: cs.outline),
        ),
        title: Text(l10n.deleteAccountConfirm,
            style: localeFont(fontWeight: FontWeight.bold)),
        content: Text(l10n.deleteAccountBody(_a.name),
            style: localeFont(height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancelLabel, style: localeFont())),
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
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: cs.outline),
        ),
        title: Text(l10n.pickNewDefaultTitle,
            style: localeFont(fontWeight: FontWeight.bold)),
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
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    onTap: () => Navigator.pop(ctx, acc),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline),
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
                            child: Text(acc.name,
                                style: localeFont(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface)),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant, size: 20),
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
              child: Text(l10n.cancelLabel, style: localeFont())),
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
      appBar: KuberAppBar(showBack: true, title: context.l10n.editAccount),
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
                      child: Text(context.l10n.couldntLoadBalance,
                          style: localeFont(
                              color: Theme.of(context).colorScheme.error)),
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
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final symbol = ref.watch(currencyProvider).symbol;
    final swatch = Color(_selectedColor ?? AppColorPalette.kVibrant.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Page header (inlined) ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 2, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.editAccount,
                  style: localeFont(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(l10n.editAccountSubtitle,
                  style:
                      localeFont(fontSize: 13.5, color: cs.onSurfaceVariant)),
            ],
          ),
        ),

        // ── Account Name ──────────────────────────────────────────────────
        const SizedBox(height: 18),
        KuberFieldLabel(l10n.accountNameLabel),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: localeFont(color: cs.onSurface, fontSize: 15),
          decoration: InputDecoration(hintText: l10n.accountNameHint),
        ),

        // ── Account Type (read-only, locked) ──────────────────────────────
        const SizedBox(height: 18),
        KuberFieldLabel(l10n.accountTypeLabel),
        _ReadOnlyTypeRow(
          typeName: _typeName(l10n),
          icon: _typeIcon(),
          tooltip: l10n.accountTypeLockedTooltip,
          onInfoTap: _showTypeInfo,
        ),

        // ── Icon + Color ──────────────────────────────────────────────────
        const SizedBox(height: 18),
        KuberPickerRow(
          leading: KuberLeadingSwatch(
            color: swatch,
            icon: IconMapper.fromString(
                _selectedIcon ?? IconMapper.kAccountIconKeys.first),
          ),
          label: l10n.iconLabel,
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
        const SizedBox(height: 10),
        KuberPickerRow(
          leading: Container(
            decoration: BoxDecoration(
              color: swatch,
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          label: l10n.colorLabel,
          value: AppColorPalette.nameFor(
              _selectedColor ?? AppColorPalette.kVibrant.first),
          onTap: () => showColorPicker(
            context: context,
            selected: _selectedColor,
            onSelected: (value) => setState(() => _selectedColor = value),
          ),
        ),

        // ── Default toggle ────────────────────────────────────────────────
        const SizedBox(height: 18),
        KuberSwitchRow(
          icon: Icons.star_rounded,
          name: l10n.makeDefaultAccount,
          sub: l10n.makeDefaultAccountSub,
          value: _isDefault,
          onChanged: (v) => setState(() => _isDefault = v),
        ),

        // ── Identifier (bank + credit only) ───────────────────────────────
        if (_showIdentifier) ...[
          const SizedBox(height: 18),
          KuberFieldLabel(l10n.accountIdentifierLabel, optional: true),
          TextField(
            controller: _last4Controller,
            keyboardType: TextInputType.number,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: localeFont(color: cs.onSurface, fontSize: 15),
            decoration:
                InputDecoration(hintText: l10n.accountIdentifierHint),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(l10n.accountIdentifierHelper,
                style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)),
          ),
        ],

        // ── HERO: Current Balance / Limit Spent ───────────────────────────
        const SizedBox(height: 26),
        KuberHeroAmountInput(
          label: _isCredit ? l10n.limitSpentLabel : l10n.currentBalanceLabel,
          currencySymbol: symbol,
          controller: _valueController,
          tone: _isCredit ? HeroAmountTone.expense : HeroAmountTone.neutral,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
        ),
        const SizedBox(height: 10),
        _AdjustmentIndicator(
          hasChange: _hasAdjustment,
          increased: _diffSigned > 0,
          restHelper: l10n.balanceAdjustHelper,
          changedText: _hasAdjustment
              ? (_diffSigned > 0
                  ? l10n.adjustmentWillBeCredited(
                      _formatCurrency(_diffSigned.abs()))
                  : l10n.adjustmentWillBeDebited(
                      _formatCurrency(_diffSigned.abs())))
              : '',
        ),

        // ── Total Limit (credit only, plain field, no adjustment) ─────────
        if (_isCredit) ...[
          const SizedBox(height: 18),
          KuberFieldLabel(l10n.totalLimitLabel),
          TextField(
            controller: _limitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: localeFont(color: cs.onSurface, fontSize: 15),
            decoration: InputDecoration(
              prefixText: '$symbol ',
              prefixStyle: localeFont(color: cs.onSurfaceVariant, fontSize: 15),
              hintText: '0',
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(l10n.totalLimitHelper,
                style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant)),
          ),
        ],

        // ── Danger Zone: disable toggle + delete ──────────────────────────
        const SizedBox(height: 30),
        KuberFieldLabel(l10n.dangerZone),
        const SizedBox(height: 4),
        KuberSwitchRow(
          icon: _isDisabled
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          name: _isDisabled
              ? l10n.accountDisabledToggle
              : l10n.disableAccountToggle,
          sub: _isDisabled
              ? l10n.accountDisabledHelper
              : l10n.disableAccountHelper,
          value: _isDisabled,
          onChanged: (v) => setState(() => _isDisabled = v),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: l10n.deleteAccount,
          type: AppButtonType.danger,
          fullWidth: true,
          height: 46,
          icon: Icons.delete_outline_rounded,
          onPressed: _onDelete,
        ),
      ],
    );
  }

  String _typeName(AppLocalizations l10n) {
    if (_isCredit) return l10n.accountTypeCreditCard;
    if (_isCash) return l10n.accountTypeCash;
    return l10n.accountTypeBank;
  }

  IconData _typeIcon() {
    if (_isCredit) return Icons.credit_card_rounded;
    if (_isCash) return Icons.payments_rounded;
    return Icons.account_balance_rounded;
  }

  Widget _buildBottomBar() {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final navInset = MediaQuery.of(context).viewPadding.bottom; // 3-button inset
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline, width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + navInset),
        child: AppButton(
          label: l10n.saveChanges,
          type: AppButtonType.primary,
          fullWidth: true,
          height: 50,
          isLoading: _saving,
          onPressed: _onSave,
        ),
      ),
    );
  }
}

// =============================================================================
// Read-only Account Type row — muted surface, lock glyph, info button only.
// =============================================================================
class _ReadOnlyTypeRow extends StatelessWidget {
  final String typeName;
  final IconData icon;
  final String tooltip;
  final VoidCallback onInfoTap;
  const _ReadOnlyTypeRow({
    required this.typeName,
    required this.icon,
    required this.tooltip,
    required this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(typeName,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.lock_outline_rounded,
                    size: 13,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
              ],
            ),
          ),
          IconButton(
            onPressed: onInfoTap,
            visualDensity: VisualDensity.compact,
            splashRadius: 18,
            icon: Icon(Icons.info_outline_rounded,
                size: 18, color: cs.onSurfaceVariant),
            tooltip: tooltip,
          ),
        ],
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
            Icon(Icons.sync_alt_rounded,
                size: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(restHelper,
                  style: localeFont(
                      fontSize: 12, height: 1.4, color: cs.onSurfaceVariant)),
            ),
          ],
        ),
      );
    }

    final tone = increased ? cs.tertiary : cs.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: tone.withValues(alpha: 0.32)),
      ),
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
            child: Text(changedText,
                style: localeFont(
                    fontSize: 12.5, height: 1.35, color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
