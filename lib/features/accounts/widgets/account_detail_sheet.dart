import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, settingsProvider;
import '../../../shared/widgets/timed_snackbar.dart';
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/utils/icon_mapper.dart';
import 'edit_balance_sheet.dart';

class AccountDetailSheet extends ConsumerWidget {
  final Account account;

  const AccountDetailSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final balanceAsync = ref.watch(accountBalanceProvider(account.id));
    final latestTxnAsync =
        ref.watch(accountLatestTransactionProvider(account.id));
    final defaultAccountId = ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.defaultAccountId),
    );
    final isDefault = defaultAccountId == account.id.toString();

    final lastTxn = latestTxnAsync.valueOrNull;
    final lastTxnLabel = lastTxn != null
        ? '${DateFormat('MMM d, yyyy').format(lastTxn.createdAt)} • ${DateFormatter.time(lastTxn.createdAt)}'
        : null;

    final rows = <InfoTableRow>[
      InfoTableDataRow(
        label: context.l10n.accountTypeLabel,
        value: account.isCreditCard
            ? context.l10n.creditCardLabel
            : context.l10n.savingsAccount,
      ),
      if (account.last4Digits != null && account.last4Digits!.isNotEmpty)
        InfoTableDataRow(
          label: context.l10n.accountNumberLabel,
          value: '•••• ${account.last4Digits}',
        ),
      InfoTableDataRow(
        label: context.l10n.defaultAccountLabel,
        value: isDefault ? context.l10n.yesLabel : context.l10n.noLabel,
        valueColor: isDefault ? null : cs.onSurfaceVariant,
      ),
      if (lastTxnLabel != null)
        InfoTableDataRow(
          label: context.l10n.lastTransactionLabel,
          value: lastTxnLabel,
        ),
    ];

    return KuberBottomSheet(
      title: account.name,
      subtitle: account.isCreditCard
          ? context.l10n.creditCardLabel
          : context.l10n.savingsAccount,
      leadingIcon: CategoryIcon.square(
        icon: account.icon != null
            ? IconMapper.fromString(account.icon!)
            : Icons.account_balance,
        rawColor: account.colorValue != null
            ? Color(account.colorValue!)
            : cs.primary,
        size: 48,
      ),
      actions: SheetButtonSection(
        padding: EdgeInsets.zero,
        primary: SheetAction(
          label: context.l10n.viewTransactions,
          icon: Icons.receipt_long_rounded,
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(historyFilterProvider.notifier).clearAll();
            ref.read(historyFilterProvider.notifier).setFilters(
                  accountIds: {account.id.toString()},
                );
            context.go('/history');
          },
        ),
        actions: [
          SheetAction(
            label: account.isCreditCard
                ? context.l10n.editLimitSpent
                : context.l10n.balanceLabel,
            icon: Icons.account_balance_wallet_rounded,
            onPressed: () => _editBalance(context, ref, balanceAsync),
          ),
          SheetAction(
            label: account.isDisabled
                ? context.l10n.enableAccount
                : context.l10n.disableAccount,
            icon: account.isDisabled
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            onPressed: () => _toggleDisabled(context, ref),
          ),
          SheetAction(
            label: context.l10n.editAccount,
            icon: Icons.edit_rounded,
            onPressed: () {
              Navigator.pop(context);
              context.push('/accounts/edit', extra: account);
            },
          ),
          SheetAction(
            label: isDefault
                ? context.l10n.removeDefault
                : context.l10n.setAsDefaultLabel,
            icon: isDefault
                ? Icons.check_circle_rounded
                : Icons.star_outline_rounded,
            onPressed: () => _toggleDefault(context, ref, isDefault),
          ),
          SheetAction(
            label: context.l10n.deleteAccount,
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          balanceAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 32,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => Text(context.l10n.errorLoadingBalance,
                style: localeFont(color: cs.error)),
            data: (balance) {
              if (account.isCreditCard) {
                return _buildCreditCardSection(context, ref, balance);
              }
              return SheetAmountHero(
                caption: context.l10n.currentAvailableBalance,
                amount: ref.watch(formatterProvider).formatCurrency(balance),
                amountColor: balance < 0
                    ? cs.error
                    : (balance > 0 ? cs.tertiary : cs.onSurface),
              );
            },
          ),
          const SizedBox(height: 18),
          InfoTable(rows: rows),
        ],
      ),
    );
  }

  void _editBalance(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<double> balanceAsync,
  ) {
    Navigator.pop(context);
    final balance = balanceAsync.valueOrNull ?? 0.0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
      ),
      builder: (_) => EditBalanceSheet(
        account: account,
        currentValue: balance,
        isCredit: account.isCreditCard,
      ),
    );
  }

  void _toggleDefault(BuildContext context, WidgetRef ref, bool isDefault) {
    ref.read(settingsProvider.notifier).setDefaultAccountId(
          isDefault ? null : account.id.toString(),
        );
    showKuberSnackBar(
      context,
      isDefault
          ? context.l10n.defaultAccountCleared
          : context.l10n.setAsDefault(account.name),
    );
  }

  void _toggleDisabled(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(allAccountsProvider.notifier);
    // The snackbar must outlive the sheet, so anchor it to the root navigator's
    // context rather than this sheet's (which is torn down on pop).
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final id = account.id;

    if (account.isDisabled) {
      // Re-enable: no confirmation needed.
      notifier.setDisabled(id, false);
      Navigator.pop(context);
      showKuberSnackBar(rootContext, rootContext.l10n.accountRestored);
      return;
    }

    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(context.l10n.disableAccount,
            style: localeFont(fontWeight: FontWeight.bold)),
        content: Text(context.l10n.disableAccountConfirm, style: localeFont()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelLabel, style: localeFont()),
          ),
          AppButton(
            label: context.l10n.confirmLabel,
            type: AppButtonType.primary,
            onPressed: () {
              notifier.setDisabled(id, true);
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close sheet
              showKuberSnackBar(
                rootContext,
                rootContext.l10n.accountHidden,
                actionLabel: rootContext.l10n.undoLabel,
                onAction: () {
                  notifier.setDisabled(id, false);
                  showKuberSnackBar(
                    rootContext,
                    rootContext.l10n.accountRestored,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardSection(
      BuildContext context, WidgetRef ref, double balance) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final limit = account.creditLimit ?? 0.1; // avoid div by 0
    final utilized = balance.abs();
    final remaining = (account.creditLimit ?? 0) - utilized;
    final percent = (utilized / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.limitSpent,
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.formatCurrency(utilized),
                  style: localeFont(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: utilized > 0 ? cs.error : cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l10n.totalLimit,
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.formatCurrency(account.creditLimit ?? 0),
                  style: localeFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.utilizedPct((percent * 100).toInt().toString()),
              style: localeFont(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Text(
              '${context.l10n.remainingUpper}: ${formatter.formatCurrency(remaining)}',
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(cs.error.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final repo = ref.read(accountRepositoryProvider);
    final hasTxns = await repo.hasTransactions(account.id);

    if (!context.mounted) return;

    if (hasTxns) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text(context.l10n.cannotDeleteAccount,
              style: localeFont(fontWeight: FontWeight.bold)),
          content: Text(
              context.l10n.cannotDeleteAccountBody,
              style: localeFont()),
          actions: [
            AppButton(
              label: context.l10n.okLabel,
              type: AppButtonType.primary,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text(context.l10n.deleteAccountConfirm,
              style: localeFont(fontWeight: FontWeight.bold)),
          content: Text(
              context.l10n.deleteAccountBody(account.name),
              style: localeFont()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.l10n.cancelLabel, style: localeFont()),
            ),
            AppButton(
              label: context.l10n.deleteLabel,
              type: AppButtonType.primary,
              onPressed: () {
                ref.read(allAccountsProvider.notifier).delete(account.id);
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close sheet
              },
            ),
          ],
        ),
      );
    }
  }
}
