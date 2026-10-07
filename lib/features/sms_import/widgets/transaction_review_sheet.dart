import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../screens/sms_import_widgets.dart' show SmsTypeGlyph;
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../pro/feature_gates/gate_sheet_sms_import.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/sms_import_repository.dart';
import '../data/sms_import_usage.dart';
import '../data/sms_transaction.dart';
import '../providers/sms_account_mapping_provider.dart';
import '../providers/sms_import_provider.dart';

/// Opens the review sheet for a staged SMS. Returns true if the transaction was
/// imported, false/null otherwise. [countsTowardLimit] is false for the paste
/// flow (always free) and true for list-tap imports (counted for free users).
Future<bool?> showSmsReviewSheet(
  BuildContext context,
  SmsTransaction sms, {
  bool countsTowardLimit = true,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        TransactionReviewSheet(sms: sms, countsTowardLimit: countsTowardLimit),
  );
}

class TransactionReviewSheet extends ConsumerStatefulWidget {
  final SmsTransaction sms;
  final bool countsTowardLimit;
  const TransactionReviewSheet({
    super.key,
    required this.sms,
    this.countsTowardLimit = true,
  });

  @override
  ConsumerState<TransactionReviewSheet> createState() =>
      _TransactionReviewSheetState();
}

class _TransactionReviewSheetState
    extends ConsumerState<TransactionReviewSheet> {
  late String _name;
  late double _amount;
  late String _type;
  int? _accountId;
  int? _categoryId;
  late DateTime _date;
  bool _smsExpanded = true;
  bool _saving = false;

  late final TextEditingController _amountController;
  late final bool _isIndian;

  /// usageCount of the learned mapping for this sender, when it auto-filled.
  int? _learnedUsageCount;

  @override
  void initState() {
    super.initState();
    final s = widget.sms;
    _name = s.parsedMerchant ?? s.senderId;
    _amount = s.parsedAmount;
    _type = s.parsedType;
    _accountId = int.tryParse(s.suggestedAccountId ?? '');
    _categoryId = int.tryParse(s.suggestedCategoryId ?? '');
    _date = s.parsedDate;

    _isIndian = ref.read(formatterProvider).system == NumberSystem.indian;
    _amountController = TextEditingController();
    _setAmountText(_amount);
    _loadLearned();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Writes [value] into the amount field with grouping applied.
  void _setAmountText(double value) {
    final raw = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    _amountController.value = CurrencyInputFormatter(isIndian: _isIndian)
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: raw,
            selection: TextSelection.collapsed(offset: raw.length),
          ),
        );
  }

  void _onAmountChanged(String text) {
    final parsed = double.tryParse(text.replaceAll(',', '').trim());
    setState(() => _amount = parsed ?? 0);
  }

  void _openCalculator() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberCalculator(
        initialValue: _amount,
        onConfirm: (result) {
          _setAmountText(result);
          setState(() => _amount = result);
        },
      ),
    );
  }

  Future<void> _loadLearned() async {
    final mapping = await ref
        .read(smsAccountMappingProvider.notifier)
        .getSuggestedAccount(widget.sms.senderId);
    if (!mounted) return;
    if (mapping != null &&
        mapping.usageCount >= 3 &&
        _accountId != null &&
        mapping.accountId == _accountId.toString()) {
      setState(() => _learnedUsageCount = mapping.usageCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accounts = ref.watch(accountMapProvider).valueOrNull;
    final categories = ref.watch(categoryMapProvider).valueOrNull;
    final isIncome = _type == 'income';
    final amountColor = isIncome
        ? context.kuberMoney.income
        : context.kuberMoney.expense;
    final symbol = ref.watch(currencyProvider).symbol;

    final account = _accountId == null ? null : accounts?[_accountId];
    final category = _categoryId == null ? null : categories?[_categoryId];
    final amountStyle = theme.textTheme.displaySmall!.copyWith(
      color: amountColor,
    );

    // Board 3.9a review sheet = the transaction sheet layout (3.3): type
    // circle + "Review SMS" overline + merchant title, amount hero, type
    // segmented, grouped editable rows, original SMS, Dismiss / Add.
    return KuberBottomSheet(
      leadingIcon: SmsTypeGlyph(type: _type, size: 48),
      subtitle: 'Review SMS',
      title: _name,
      actions: _buildActions(cs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KuberSectionHeader(title: 'Amount'),
          // The amount is plain text on the sheet (no inner field box).
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                symbol,
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: KuberSpace.xs),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  onChanged: _onAmountChanged,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    CurrencyInputFormatter(isIndian: _isIndian),
                  ],
                  style: amountStyle,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: amountStyle.copyWith(color: cs.onSurfaceVariant),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              AppIconButton(
                icon: Icons.calculate_outlined,
                semanticLabel: 'Calculator',
                onPressed: _openCalculator,
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.lg),
          KuberSegmentedControl<String>(
            values: const ['expense', 'income'],
            labels: const ['Expense', 'Income'],
            selected: _type,
            onSelected: (t) => setState(() => _type = t),
            height: 40,
          ),
          const SizedBox(height: KuberSpace.lg),
          if (_learnedUsageCount != null)
            _LearnedBanner(
              accountName: account?.name ?? 'account',
              sender: widget.sms.senderId,
              count: _learnedUsageCount!,
            ),
          KuberGroup(
            children: [
              KuberListRow(
                leading: const KuberIconTile(icon: Icons.notes_rounded),
                title: _name,
                subtitle: 'Name',
                trailing: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                onTap: _editName,
              ),
              _PickRow(
                icon: account != null
                    ? resolveAccountIcon(account)
                    : Icons.account_balance_wallet_outlined,
                value: account == null
                    ? 'Select account'
                    : account.name +
                          (account.last4Digits != null
                              ? '  ·  ${account.last4Digits}'
                              : ''),
                label: 'Account',
                missing: account == null,
                tint: account == null ? null : resolveAccountColor(account),
                onTap: _pickAccount,
              ),
              _PickRow(
                icon: category != null
                    ? IconMapper.fromString(category.icon)
                    : Icons.category_outlined,
                value: category?.name ?? 'Pick category',
                label: 'Category',
                missing: category == null,
                tint: category == null ? null : Color(category.colorValue),
                onTap: _pickCategory,
              ),
              KuberListRow(
                leading: const KuberIconTile(
                  icon: Icons.calendar_today_outlined,
                ),
                title: DateFormat('d MMM yyyy · h:mm a').format(_date),
                subtitle: 'Date & time',
                trailing: const KuberChevron(),
                onTap: _pickDate,
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.xl),
          _SmsDisclosure(
            sms: widget.sms,
            expanded: _smsExpanded,
            onToggle: () => setState(() => _smsExpanded = !_smsExpanded),
          ),
        ],
      ),
    );
  }

  /// Action buttons depend on the row's review status:
  /// - unreviewed: Dismiss + Add transaction
  /// - dismissed: only Add transaction (a chance to reconsider)
  /// - imported: none (view only)
  Widget? _buildActions(ColorScheme cs) {
    final status = widget.sms.reviewStatus;
    if (status == SmsReviewStatus.imported) return null;

    final needAccount = _accountId == null;
    final needCategory = _categoryId == null;
    final addButton = AppButton(
      label: 'Add transaction',
      icon: Icons.check_rounded,
      type: AppButtonType.primary,
      fullWidth: true,
      isLoading: _saving,
      onPressed: (needAccount || needCategory || _amount <= 0)
          ? null
          : _addToKuber,
    );

    final String? blockReason = _amount > 0
        ? (needAccount && needCategory
              ? 'Pick an account and a category to add this'
              : needAccount
              ? 'Pick an account to add this'
              : needCategory
              ? 'Pick a category to add this'
              : null)
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (blockReason != null) ...[
          Text(
            blockReason,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: cs.error),
          ),
          const SizedBox(height: KuberSpace.sm),
        ],
        Row(
          children: [
            if (status == SmsReviewStatus.unreviewed) ...[
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Dismiss',
                  type: AppButtonType.outline,
                  fullWidth: true,
                  onPressed: _saving ? null : _dismiss,
                ),
              ),
              const SizedBox(width: KuberSpace.md),
            ],
            Expanded(flex: 3, child: addButton),
          ],
        ),
      ],
    );
  }

  Future<void> _editName() async {
    final result = await _editTextDialog(
      context,
      title: 'Name',
      initial: _name,
    );
    if (result != null) setState(() => _name = result);
  }

  void _pickAccount() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: KuberShape.sheetR),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: _accountId,
        onSelected: (id) {
          setState(() {
            _accountId = id;
            _learnedUsageCount = null; // user overrode the suggestion
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _categoryId,
        defaultType: _type,
        onSelected: (id) {
          setState(() => _categoryId = id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? _date.hour,
        time?.minute ?? _date.minute,
      );
    });
  }

  Future<void> _addToKuber() async {
    final notifier = ref.read(smsImportProvider.notifier);
    final accountId = _accountId.toString();

    // Duplicate detection: same amount + account + date +/- 1 day.
    final dup = notifier.findDuplicate(
      amount: _amount,
      accountId: accountId,
      date: _date,
    );
    if (dup != null && mounted) {
      final proceed = await _showDuplicateDialog(dup);
      if (proceed != true) return;
    }

    setState(() => _saving = true);
    final outcome = await notifier.importSingleGated(
      widget.sms,
      name: _name,
      amount: _amount,
      type: _type,
      accountId: accountId,
      categoryId: _categoryId?.toString(),
      date: _date,
      countsTowardLimit: widget.countsTowardLimit,
    );
    if (!mounted) return;
    if (outcome == SmsSingleImportOutcome.blocked) {
      // Weekly free-tier cap hit: keep the sheet open and surface the limit.
      setState(() => _saving = false);
      final resetDate = await SmsImportUsage.resetDate();
      if (mounted) {
        showSmsImportLimitGateSheet(context, resetDate: resetDate);
      }
      return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _dismiss() async {
    final cs = Theme.of(context).colorScheme;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss message?'),
        content: const Text(
          'Are you sure you want to dismiss this message? You can find it later under the "Dismissed" tab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      await ref.read(smsImportProvider.notifier).dismiss(widget.sms);
      if (mounted) Navigator.pop(context, false);
    }
  }

  Future<bool?> _showDuplicateDialog(dynamic existing) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.read(currencyProvider).symbol;
    final formatter = ref.read(formatterProvider);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.kuberMoney.warningContainer,
                      borderRadius: KuberShape.mediumR,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: context.kuberMoney.onWarningContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A similar transaction may already exist',
                      style: Theme.of(
                        ctx,
                      ).textTheme.titleLarge!.copyWith(color: cs.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'In your history:',
                style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: KuberShape.mediumR,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        existing.name as String,
                        style: localeFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      (existing.type == 'income' ? '+' : '−') +
                          formatter.formatCurrency(
                            existing.amount as double,
                            symbol: symbol,
                          ),
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: existing.type == 'income'
                            ? context.kuberMoney.income
                            : context.kuberMoney.expense,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      type: AppButtonType.normal,
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      label: 'Add anyway',
                      type: AppButtonType.primary,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Account / category row: value as the title, field name under it. A
/// missing required value shows in the error colour (it blocks Add).
class _PickRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool missing;
  final Color? tint;
  final VoidCallback onTap;

  const _PickRow({
    required this.icon,
    required this.value,
    required this.label,
    required this.missing,
    required this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tones = tint == null ? null : categoryTones(context, tint!);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: missing
                    ? cs.errorContainer
                    : (tones?.container ?? cs.secondaryContainer),
                borderRadius: KuberShape.mediumR,
              ),
              child: Icon(
                icon,
                size: 20,
                color: missing
                    ? cs.onErrorContainer
                    : (tones?.fg ?? cs.onSecondaryContainer),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: missing ? cs.error : cs.onSurface,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: missing ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const KuberChevron(),
          ],
        ),
      ),
    );
  }
}

class _LearnedBanner extends StatelessWidget {
  final String accountName;
  final String sender;
  final int count;
  const _LearnedBanner({
    required this.accountName,
    required this.sender,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: KuberSpace.md),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.largeR,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: cs.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Auto-filled $accountName '),
                  TextSpan(text: 'used $count times from '),
                  TextSpan(
                    text: sender,
                    style: monoFont(
                      fontSize: 12,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: cs.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmsDisclosure extends StatelessWidget {
  final SmsTransaction sms;
  final bool expanded;
  final VoidCallback onToggle;
  const _SmsDisclosure({
    required this.sms,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberSectionHeader(
          title: 'Original SMS',
          onTitleTap: onToggle,
          trailing: AppIconButton(
            icon: expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            kind: AppIconButtonKind.plain,
            semanticLabel: expanded ? 'Hide SMS' : 'Show SMS',
            onPressed: onToggle,
          ),
        ),
        Text(
          'From ${sms.senderId}'
          '${sms.patternMatched != null ? ' · matched ${sms.patternMatched} pattern' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall!.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: KuberSpace.sm),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: KuberShape.mediumR,
            ),
            child: Text(
              sms.rawSms,
              style: monoFont(
                fontSize: 13,
                height: 1.55,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Edit dialogs ────────────────────────────────────────────────────────────

Future<String?> _editTextDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
