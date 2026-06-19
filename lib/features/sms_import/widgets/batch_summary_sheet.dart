import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/sms_transaction.dart';
import '../providers/sms_import_provider.dart';
import '../screens/sms_import_widgets.dart';

/// Shows the batch confirm sheet. [onImported] runs after a successful import
/// so the caller can leave multi-select mode.
void showBatchSummarySheet(
  BuildContext context, {
  required List<SmsTransaction> selected,
  required VoidCallback onImported,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BatchSummarySheet(
      selected: selected,
      onImported: onImported,
    ),
  );
}

class BatchSummarySheet extends ConsumerStatefulWidget {
  final List<SmsTransaction> selected;
  final VoidCallback onImported;

  const BatchSummarySheet({
    super.key,
    required this.selected,
    required this.onImported,
  });

  @override
  ConsumerState<BatchSummarySheet> createState() => _BatchSummarySheetState();
}

class _BatchSummarySheetState extends ConsumerState<BatchSummarySheet> {
  bool _importing = false;

  /// A common account / category applied to any selected row that does not
  /// already have one of its own.
  int? _commonAccountId;
  int? _commonCategoryId;

  /// Effective account/category for a row: its own suggestion, else the common
  /// pick. Returned as the string ids the import uses.
  String? _accountFor(SmsTransaction s) =>
      s.suggestedAccountId ?? _commonAccountId?.toString();
  String? _categoryFor(SmsTransaction s) =>
      s.suggestedCategoryId ?? _commonCategoryId?.toString();

  /// Rows that can be imported: those with an effective account.
  List<SmsTransaction> get _importable =>
      widget.selected.where((s) => _accountFor(s) != null).toList();

  /// How many selected rows are still missing an account (no own, no common).
  int get _missingAccount =>
      widget.selected.where((s) => s.suggestedAccountId == null).length;
  int get _missingCategory =>
      widget.selected.where((s) => s.suggestedCategoryId == null).length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(smsImportProvider.notifier);
    final importable = _importable;
    final needsReview = widget.selected.length - importable.length;

    final expenseTotal = importable
        .where((s) => s.parsedType == 'expense')
        .fold<double>(0, (sum, s) => sum + s.parsedAmount);
    final incomeTotal = importable
        .where((s) => s.parsedType == 'income')
        .fold<double>(0, (sum, s) => sum + s.parsedAmount);

    final dupCount = importable.where((s) {
      return notifier.findDuplicate(
            amount: s.parsedAmount,
            accountId: _accountFor(s)!,
            date: s.parsedDate,
          ) !=
          null;
    }).length;

    return KuberBottomSheet(
      title: 'Add ${importable.length} transactions',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'Confirm import',
            type: AppButtonType.primary,
            fullWidth: true,
            isLoading: _importing,
            onPressed: importable.isEmpty ? null : _confirm,
          ),
          TextButton(
            onPressed: _importing ? null : () => Navigator.pop(context),
            child: Text(
              'Review individually',
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dupCount > 0) _DupBanner(count: dupCount),
          // Common account / category, applied to rows missing their own.
          if (_missingAccount > 0 || _missingCategory > 0) ...[
            Text(
              'APPLY TO ALL MISSING',
              style: localeFont(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            _CommonPickerRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Account',
              value: _commonAccountName(),
              hint: '$_missingAccount missing',
              onTap: _pickCommonAccount,
            ),
            const SizedBox(height: 8),
            _CommonPickerRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: _commonCategoryName(),
              dotColor: _commonCategoryColor(context),
              hint: '$_missingCategory missing',
              onTap: _pickCommonCategory,
            ),
            const SizedBox(height: 14),
          ],
          if (needsReview > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '$needsReview selected still need an account. Pick a common '
                'account above, or review them individually.',
                style: localeFont(
                  fontSize: 11.5,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          // Compact list.
          ...importable.map((s) => _BatchRow(sms: s)),
          const SizedBox(height: 12),
          Divider(height: 1, color: cs.outline),
          const SizedBox(height: 12),
          _TotalRow(label: 'Expense', amount: expenseTotal, type: 'expense'),
          const SizedBox(height: 6),
          _TotalRow(label: 'Income', amount: incomeTotal, type: 'income'),
        ],
      ),
    );
  }

  String? _commonAccountName() {
    if (_commonAccountId == null) return null;
    return ref.read(accountMapProvider).valueOrNull?[_commonAccountId]?.name;
  }

  String? _commonCategoryName() {
    if (_commonCategoryId == null) return null;
    return ref.read(categoryMapProvider).valueOrNull?[_commonCategoryId]?.name;
  }

  Color? _commonCategoryColor(BuildContext context) {
    if (_commonCategoryId == null) return null;
    final cat = ref.read(categoryMapProvider).valueOrNull?[_commonCategoryId];
    return cat == null ? null : harmonizeCategory(context, Color(cat.colorValue));
  }

  void _pickCommonAccount() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: _commonAccountId,
        onSelected: (id) {
          setState(() => _commonAccountId = id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _pickCommonCategory() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _commonCategoryId,
        onSelected: (id) {
          setState(() => _commonCategoryId = id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() => _importing = true);
    final drafts = _importable
        .map((s) => SmsImportDraft(
              sms: s,
              name: s.parsedMerchant ?? s.senderId,
              amount: s.parsedAmount,
              type: s.parsedType,
              accountId: _accountFor(s)!,
              categoryId: _categoryFor(s),
              date: s.parsedDate,
            ))
        .toList();
    await ref.read(smsImportProvider.notifier).importBatch(drafts);
    if (!mounted) return;
    Navigator.pop(context);
    widget.onImported();
  }
}

/// A tappable "apply to all" picker row in the batch sheet.
class _CommonPickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String hint;
  final Color? dotColor;
  final VoidCallback onTap;

  const _CommonPickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasValue = value != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(
              label,
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (hasValue && dotColor != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                hasValue ? value! : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: localeFont(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _DupBanner extends StatelessWidget {
  final int count;
  const _DupBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberColors.warning;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count of the selected transactions may already exist. '
              'Continue anyway?',
              style: localeFont(
                fontSize: 12,
                color: cs.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchRow extends ConsumerWidget {
  final SmsTransaction sms;
  const _BatchRow({required this.sms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final amountColor = sms.parsedType == 'income' ? cs.tertiary : cs.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              sms.parsedMerchant ?? sms.senderId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            signedAmount(ref, sms.parsedAmount, sms.parsedType),
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends ConsumerWidget {
  final String label;
  final double amount;
  final String type;
  const _TotalRow({
    required this.label,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final color = type == 'income' ? cs.tertiary : cs.error;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: localeFont(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          amount == 0 ? '-' : signedAmount(ref, amount, type),
          style: localeFont(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: amount == 0 ? cs.onSurfaceVariant : color,
          ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
