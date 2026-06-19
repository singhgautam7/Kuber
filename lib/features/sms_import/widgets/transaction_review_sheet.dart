import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/sms_import_repository.dart';
import '../data/sms_transaction.dart';
import '../providers/sms_account_mapping_provider.dart';
import '../providers/sms_import_provider.dart';

/// Opens the review sheet for a staged SMS. Returns true if the transaction was
/// imported, false/null otherwise.
Future<bool?> showSmsReviewSheet(BuildContext context, SmsTransaction sms) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TransactionReviewSheet(sms: sms),
  );
}

class TransactionReviewSheet extends ConsumerStatefulWidget {
  final SmsTransaction sms;
  const TransactionReviewSheet({super.key, required this.sms});

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
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
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
    final cs = Theme.of(context).colorScheme;
    final accounts = ref.watch(accountMapProvider).valueOrNull;
    final categories = ref.watch(categoryMapProvider).valueOrNull;
    final isIncome = _type == 'income';
    final amountColor = isIncome ? cs.tertiary : cs.error;
    final symbol = ref.watch(currencyProvider).symbol;

    final account = _accountId == null ? null : accounts?[_accountId];
    final category = _categoryId == null ? null : categories?[_categoryId];

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Review transaction',
                      style: localeFont(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Amount ──
                    Text(
                      'AMOUNT',
                      style: localeFont(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      // Same fill as the sheet so the field reads as one piece,
                      // not a box-within-a-box.
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Row(
                        children: [
                          Text(
                            symbol,
                            style: localeFont(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              onChanged: _onAmountChanged,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                CurrencyInputFormatter(isIndian: _isIndian),
                              ],
                              style: localeFont(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: amountColor,
                                letterSpacing: -1,
                              ).copyWith(fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ]),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: localeFont(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: -1,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _openCalculator,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh,
                                borderRadius:
                                    BorderRadius.circular(KuberRadius.md),
                                border: Border.all(color: cs.outline),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.calculate_outlined,
                                size: 20,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ── Type segmented ──
                    _TypeSegmented(
                      type: _type,
                      onChanged: (t) => setState(() => _type = t),
                    ),
                    const SizedBox(height: 12),

                    // ── Name ──
                    _FieldRow(
                      icon: Icons.notes_rounded,
                      label: 'NAME',
                      value: _name,
                      trailing: Icons.edit_outlined,
                      onTap: _editName,
                    ),

                    // Learned mapping banner.
                    if (_learnedUsageCount != null) _LearnedBanner(
                      accountName: account?.name ?? 'account',
                      sender: widget.sms.senderId,
                      count: _learnedUsageCount!,
                    ),

                    // ── Account ──
                    _FieldRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'ACCOUNT',
                      value: account == null
                          ? 'Select account'
                          : account.name +
                              (account.last4Digits != null
                                  ? '  ·  ${account.last4Digits}'
                                  : ''),
                      muted: account == null,
                      onTap: _pickAccount,
                    ),

                    // ── Category ──
                    _FieldRow(
                      icon: Icons.category_outlined,
                      label: 'CATEGORY',
                      value: category?.name ?? 'Pick category',
                      muted: category == null,
                      leadingDot: category == null
                          ? null
                          : harmonizeCategory(
                              context, Color(category.colorValue)),
                      onTap: _pickCategory,
                    ),

                    // ── Date ──
                    _FieldRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'DATE',
                      value: DateFormat('d MMM yyyy · h:mm a').format(_date),
                      onTap: _pickDate,
                    ),

                    // ── Original SMS (collapsible) ──
                    _SmsDisclosure(
                      sms: widget.sms,
                      expanded: _smsExpanded,
                      onToggle: () =>
                          setState(() => _smsExpanded = !_smsExpanded),
                    ),
                  ],
                ),
              ),
            ),
            _buildActions(cs),
          ],
        ),
      ),
    );
  }

  /// Action buttons depend on the row's review status:
  /// - unreviewed: Add to Kuber + Dismiss
  /// - dismissed: only Add to Kuber (a chance to reconsider)
  /// - imported: no buttons (view only)
  Widget _buildActions(ColorScheme cs) {
    final status = widget.sms.reviewStatus;
    if (status == SmsReviewStatus.imported) {
      return const SizedBox(height: 12);
    }

    final addButton = AppButton(
      label: 'Add to Kuber',
      type: AppButtonType.primary,
      fullWidth: true,
      isLoading: _saving,
      onPressed: (_accountId == null || _amount <= 0) ? null : _addToKuber,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Column(
        children: [
          addButton,
          if (status == SmsReviewStatus.unreviewed)
            TextButton(
              onPressed: _saving ? null : _dismiss,
              child: Text(
                'Dismiss',
                style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
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
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
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
    await notifier.importSingle(
      widget.sms,
      name: _name,
      amount: _amount,
      type: _type,
      accountId: accountId,
      categoryId: _categoryId?.toString(),
      date: _date,
    );
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _dismiss() async {
    await ref.read(smsImportProvider.notifier).dismiss(widget.sms);
    if (mounted) Navigator.pop(context, false);
  }

  Future<bool?> _showDuplicateDialog(dynamic existing) {
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberColors.warning;
    final symbol = ref.read(currencyProvider).symbol;
    final formatter = ref.read(formatterProvider);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: cs.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
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
                      color: warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: warning.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        size: 20, color: warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A similar transaction may already exist',
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'In your history:',
                style: localeFont(fontSize: 13, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: existing.type == 'income'
                            ? cs.tertiary
                            : cs.error,
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

class _TypeSegmented extends StatelessWidget {
  final String type;
  final ValueChanged<String> onChanged;
  const _TypeSegmented({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget seg(String value, String label, IconData icon, Color color) {
      final selected = type == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            decoration: BoxDecoration(
              color: selected ? cs.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? color : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 13,
                    color: selected ? color : cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          seg('expense', 'Expense', Icons.south_west_rounded, cs.error),
          const SizedBox(width: 3),
          seg('income', 'Income', Icons.north_east_rounded, cs.tertiary),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData trailing;
  final bool muted;
  final Color? leadingDot;
  final VoidCallback onTap;

  const _FieldRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing = Icons.chevron_right_rounded,
    this.muted = false,
    this.leadingDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outline)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Icon(icon, size: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: localeFont(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (leadingDot != null) ...[
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: leadingDot,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: localeFont(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: muted ? cs.onSurfaceVariant : cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(trailing, size: 16, color: cs.onSurfaceVariant),
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
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 14, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Auto-filled $accountName '),
                  TextSpan(
                    text: 'used $count times from ',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  TextSpan(
                    text: sender,
                    style: GoogleFonts.jetBrainsMono(color: cs.onSurface),
                  ),
                ],
              ),
              style: localeFont(
                fontSize: 11.5,
                color: cs.primary,
                height: 1.4,
              ),
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
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: Icon(Icons.sms_outlined,
                      size: 14, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expanded ? 'Original SMS' : 'View original SMS',
                        style: localeFont(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'From ${sms.senderId}'
                        '${sms.patternMatched != null ? ' · matched ${sms.patternMatched} pattern' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: localeFont(
                          fontSize: 10.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              sms.rawSms,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                height: 1.55,
                color: cs.onSurfaceVariant,
                letterSpacing: -0.1,
              ),
            ),
          ),
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
  final cs = Theme.of(context).colorScheme;
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cs.surfaceContainer,
      title: Text(title, style: localeFont(fontSize: 16, fontWeight: FontWeight.w700)),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(border: OutlineInputBorder()),
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

