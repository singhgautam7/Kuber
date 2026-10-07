import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../pro/feature_gates/gate_sheet_sms_import.dart';
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/sms_import_usage.dart';
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
    builder: (_) =>
        BatchSummarySheet(selected: selected, onImported: onImported),
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
          const SizedBox(height: KuberSpace.sm),
          TextButton(
            onPressed: _importing ? null : () => Navigator.pop(context),
            child: const Text('Review individually'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (dupCount > 0) _DupBanner(count: dupCount),
          // Common account / category, applied to rows missing their own.
          if (_missingAccount > 0 || _missingCategory > 0) ...[
            const KuberSectionHeader(title: 'Apply to all missing'),
            KuberGroup(
              children: [
                _CommonPickerRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Account',
                  value: _commonAccountName(),
                  hint: '$_missingAccount missing',
                  onTap: _pickCommonAccount,
                ),
                _CommonPickerRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: _commonCategoryName(),
                  dotColor: _commonCategoryColor(context),
                  hint: '$_missingCategory missing',
                  onTap: _pickCommonCategory,
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.lg),
          ],
          if (needsReview > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '$needsReview selected still need an account. Pick a common '
                'account above, or review them individually.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          KuberSectionHeader(title: '${importable.length} selected'),
          KuberGroup(children: [for (final s in importable) _BatchRow(sms: s)]),
          const SizedBox(height: KuberSpace.lg),
          KuberGroup(
            children: [
              _TotalRow(
                label: 'Expense',
                amount: expenseTotal,
                type: 'expense',
              ),
              _TotalRow(label: 'Income', amount: incomeTotal, type: 'income'),
            ],
          ),
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
    return cat == null
        ? null
        : harmonizeCategory(context, Color(cat.colorValue));
  }

  void _pickCommonAccount() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: KuberShape.sheetR),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
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
        .map(
          (s) => SmsImportDraft(
            sms: s,
            name: s.parsedMerchant ?? s.senderId,
            amount: s.parsedAmount,
            type: s.parsedType,
            accountId: _accountFor(s)!,
            categoryId: _categoryFor(s),
            date: s.parsedDate,
          ),
        )
        .toList();
    // Capture the host navigator/context before popping — this sheet's context
    // is defunct once dismissed, but the free-tier limit sheet/snackbar need a
    // live context.
    final nav = Navigator.of(context);
    final hostContext = nav.context;
    final outcome = await ref
        .read(smsImportProvider.notifier)
        .importBatchGated(drafts);
    if (!mounted) return;
    nav.pop();
    widget.onImported();
    if (!outcome.hasBlocked || !hostContext.mounted) return;

    // Free-tier weekly cap: some (or all) rows were left staged.
    final resetDate = await SmsImportUsage.resetDate();
    if (!hostContext.mounted) return;
    if (outcome.importedCount > 0) {
      showKuberSnackBar(
        hostContext,
        'Imported ${outcome.importedCount}, '
        '${outcome.blockedCount} left for next week',
      );
    }
    showSmsImportLimitGateSheet(hostContext, resetDate: resetDate);
  }
}

/// An "apply to all" row: value (or "n missing") as the title.
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
  Widget build(BuildContext context) => KuberListRow(
    leading: KuberIconTile(icon: icon),
    title: value ?? hint,
    subtitle: label,
    trailing: const KuberChevron(),
    onTap: onTap,
  );
}

class _DupBanner extends StatelessWidget {
  final int count;
  const _DupBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final m = context.kuberMoney;
    return Container(
      margin: const EdgeInsets.only(bottom: KuberSpace.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: m.warningContainer,
        borderRadius: KuberShape.largeR,
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: m.onWarningContainer,
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Text(
              '$count of the selected transactions may already exist. '
              'Continue anyway?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: m.onWarningContainer),
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
    final theme = Theme.of(context);
    final m = context.kuberMoney;
    return KuberListRow(
      dense: true,
      leading: SmsTypeGlyph(type: sms.parsedType),
      title: sms.parsedMerchant ?? sms.senderId,
      trailing: Text(
        signedAmount(ref, sms.parsedAmount, sms.parsedType),
        style: theme.textTheme.titleSmall!.copyWith(
          color: sms.parsedType == 'income' ? m.income : m.expense,
        ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = type == 'income'
        ? context.kuberMoney.income
        : context.kuberMoney.expense;
    return KuberListRow(
      dense: true,
      title: label,
      trailing: Text(
        amount == 0 ? '-' : signedAmount(ref, amount, type),
        style: theme.textTheme.titleMedium!.copyWith(
          color: amount == 0 ? cs.onSurfaceVariant : color,
        ),
      ),
    );
  }
}
